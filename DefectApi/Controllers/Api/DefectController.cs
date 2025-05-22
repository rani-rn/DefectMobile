using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;
using DefectApi.Models;

namespace DefectApi.Controllers.Api
{

    [ApiController]
    [Route("api/defect")]
    public class DefectController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public DefectController(ApplicationDbContext context)
        {
            _context = context;
        }
        [HttpGet("chart")]
        public IActionResult GetChartData(string timePeriod = "daily")
        {
            var today = DateTime.Today;

            DateTime startDate = timePeriod.ToLower() switch
            {
                "weekly" => today.AddDays(-(int)today.DayOfWeek + (int)DayOfWeek.Monday),
                "monthly" => new DateTime(today.Year, today.Month, 1),
                "annual" => new DateTime(today.Year, 1, 1),
                _ => today
            };

            var allDefectTypes = _context.Defect
                .Select(d => d.DefectName)
                .Distinct()
                .ToList();

            var allLineProductions = _context.LineProductions
                .Select(lp => lp.LineProductionName)
                .Distinct()
                .ToList();

            allLineProductions = allLineProductions
                .OrderBy(name =>
                {
                    var match = System.Text.RegularExpressions.Regex.Match(name, @"\d+");
                    return match.Success ? int.Parse(match.Value) : int.MaxValue;
                })
                .ToList();

            var rawData = _context.DefectReports
                .Where(d => d.ReportDate >= startDate)
                .Select(d => new
                {
                    d.Defect.DefectName,
                    d.LineProduction.LineProductionName,
                    d.DefectQty
                })
                .ToList();

            var grouped = rawData
                .GroupBy(d => new { d.DefectName, d.LineProductionName })
                .ToDictionary(
                    g => new { g.Key.DefectName, g.Key.LineProductionName },
                    g => g.Sum(x => x.DefectQty)
                );

            var colorMap = allDefectTypes.ToDictionary(
                defect => defect,
                defect => $"#{Random.Shared.Next(0x1000000):X6}"
            );

            var datasets = allDefectTypes.Select(defect => new
            {
                label = defect,
                data = allLineProductions.Select(lp =>
                    grouped.TryGetValue(new { DefectName = defect, LineProductionName = lp }, out var qty)
                        ? qty
                        : 0
                ).ToList(),
                backgroundColor = colorMap[defect]
            }).ToList();

            var summaryData = _context.DefectReports
                .Where(d => d.ReportDate >= today.AddYears(-1))
                .ToList();

            var allCounts = new
            {
                Daily = summaryData.Where(d => d.ReportDate == today).Sum(d => d.DefectQty),
                Weekly = summaryData.Where(d => d.ReportDate >= today.AddDays(-(int)today.DayOfWeek + (int)DayOfWeek.Monday)).Sum(d => d.DefectQty),
                Monthly = summaryData.Where(d => d.ReportDate >= new DateTime(today.Year, today.Month, 1)).Sum(d => d.DefectQty),
                Annual = summaryData.Sum(d => d.DefectQty)
            };

            return Ok(new
            {
                labels = allLineProductions,
                datasets = datasets,
                daily = allCounts.Daily,
                weekly = allCounts.Weekly,
                monthly = allCounts.Monthly,
                annual = allCounts.Annual
            });
        }



        [HttpGet("all")]
        public async Task<IActionResult> GetAllReports()
        {
            var defectReports = await _context.DefectReports
                .Include(d => d.Defect)
                .Include(d => d.LineProduction)
                .Include(d => d.Section)
                .Include(d => d.WpModel)
                .Select(d => new
                {
                    d.ReportId,
                    d.ReportDate,
                    d.LineProdQty,
                    d.Reporter,
                    d.Description,
                    d.DefectQty,
                    WpModel = d.WpModel != null ? new
                    {
                        d.WpModel.ModelId,
                        d.WpModel.ModelName
                    } : null,
                    Section = d.Section != null ? new
                    {
                        d.Section.SectionId,
                        d.Section.SectionName
                    } : null,
                    LineProduction = d.LineProduction != null ? new
                    {
                        d.LineProduction.Id,
                        d.LineProduction.LineProductionName
                    } : null,
                    Defect = d.Defect != null ? new
                    {
                        d.Defect.DefectId,
                        d.Defect.DefectName
                    } : null
                })
                .ToListAsync();

            return Ok(defectReports);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var d = await _context.DefectReports
                .Include(r => r.Defect)
                .Include(r => r.LineProduction)
                .Include(r => r.Section)
                .Include(r => r.WpModel)
                .Where(r => r.ReportId == id)
                .Select(r => new
                {
                    r.ReportId,
                    r.ReportDate,
                    r.LineProdQty,
                    r.Reporter,
                    r.Description,
                    r.DefectQty,
                    WpModel = r.WpModel != null ? new
                    {
                        r.WpModel.ModelId,
                        r.WpModel.ModelName
                    } : null,
                    Section = r.Section != null ? new
                    {
                        r.Section.SectionId,
                        r.Section.SectionName
                    } : null,
                    LineProduction = r.LineProduction != null ? new
                    {
                        r.LineProduction.Id,
                        r.LineProduction.LineProductionName
                    } : null,
                    Defect = r.Defect != null ? new
                    {
                        r.Defect.DefectId,
                        r.Defect.DefectName
                    } : null
                })
                .FirstOrDefaultAsync();

            if (d == null)
                return NotFound();

            return Ok(d);
        }
        public class AddDefectRequest
        {
            public string DefectName { get; set; }
        }

        [HttpPost("add-defect")]
        public async Task<IActionResult> AddDefect([FromBody] AddDefectRequest request)
        {
            if (string.IsNullOrEmpty(request.DefectName))
                return BadRequest("Defect can not empty");

            var existingDefect = await _context.Defect.FirstOrDefaultAsync(d => d.DefectName.ToLower() == request.DefectName.ToLower());

            if (existingDefect != null)
            {
                return Ok(new { success = true, message = "Defect already exist", defectId = existingDefect.DefectId });
            }

            var newDefect = new Defect { DefectName = request.DefectName };
            _context.Defect.Add(newDefect);
            await _context.SaveChangesAsync();
            return Ok(new { success = true, message = "Defect Added", defectId = newDefect.DefectId });
        }

        [HttpPost("add-report")]
        public async Task<IActionResult> AddReport([FromBody] DefectReport defectReport)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            if (defectReport.DefectId == null)
                return BadRequest("DefectId is required.");

            defectReport.Defect = null;
            defectReport.LineProduction = null;
            defectReport.Section = null;
            defectReport.WpModel = null;

            _context.DefectReports.Add(defectReport);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Report added successfully" });
        }

        [HttpPut("update/{id}")]
        public async Task<IActionResult> UpdateReport(int id, [FromBody] DefectReport defectReport)
        {
            if (id != defectReport.ReportId)
                return BadRequest("ID mismatch");

            var existingReport = await _context.DefectReports.FindAsync(id);
            if (existingReport == null)
                return NotFound();

            existingReport.Reporter = defectReport.Reporter;
            existingReport.ReportDate = defectReport.ReportDate;
            existingReport.LineProdQty = defectReport.LineProdQty;
            existingReport.SectionId = defectReport.SectionId;
            existingReport.ModelId = defectReport.ModelId;
            existingReport.LineProductionId = defectReport.LineProductionId;
            existingReport.DefectId = defectReport.DefectId;
            existingReport.Description = defectReport.Description;
            existingReport.DefectQty = defectReport.DefectQty;

            _context.DefectReports.Update(existingReport);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Data updated successfully" });
        }


        [HttpDelete("delete/{id}")]
        public async Task<IActionResult> DeleteReport(int id)
        {
            var defectReport = await _context.DefectReports.FindAsync(id);
            if (defectReport == null)
                return NotFound(new { success = false, message = "Data not found" });

            _context.DefectReports.Remove(defectReport);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Record deleted successfully" });
        }

        [HttpGet("dropdown")]
        public async Task<IActionResult> GetDropdownData()
        {
            var sections = await _context.Sections
                .Select(s => new { s.SectionId, s.SectionName })
                .ToListAsync();

            var defects = await _context.Defect
                .Select(d => new { d.DefectId, d.DefectName })
                .ToListAsync();

            var lines = await _context.LineProductions
                .Select(l => new { l.Id, l.LineProductionName })
                .ToListAsync();

            var models = await _context.WpModels
                .Select(m => new { m.ModelId, m.ModelName })
                .ToListAsync();

            return Ok(new
            {
                sections,
                defects,
                lineProductions = lines,
                models
            });
        }


    }
}
