using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
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

        private (DateTime Start, DateTime End) GetDateRange(string timePeriod)
        {
            DateTime today = DateTime.Today;
            DateTime start = timePeriod.ToLower() switch
            {
                "weekly" => today.AddDays(-(int)today.DayOfWeek + (int)DayOfWeek.Monday),
                "monthly" => new DateTime(today.Year, today.Month, 1),
                "annual" => new DateTime(today.Year, 1, 1),
                _ => today
            };
            DateTime end = today.AddDays(1).AddTicks(-1);
            return (start, end);
        }

        [HttpGet("chart")]
        public async Task<IActionResult> GetChartData(string timePeriod = "daily")
        {
            var (startDate, endDate) = GetDateRange(timePeriod);

            var allDefectTypes = await _context.Defect
                .Select(d => d.DefectName)
                .Distinct()
                .ToListAsync();

            var allLineProductions = await _context.LineProductions
                .Select(lp => lp.LineProductionName)
                .Distinct()
                .ToListAsync();

            allLineProductions = allLineProductions
                .OrderBy(name =>
                {
                    var match = System.Text.RegularExpressions.Regex.Match(name, @"\d+");
                    return match.Success ? int.Parse(match.Value) : int.MaxValue;
                })
                .ToList();

            var rawData = await _context.DefectReports
                .Where(d => d.ReportDate >= startDate && d.ReportDate <= endDate)
                .Include(d => d.Defect)
                .Include(d => d.LineProduction)
                .Select(d => new
                {
                    DefectName = d.Defect.DefectName,
                    LineProductionName = d.LineProduction.LineProductionName,
                    d.DefectQty
                })
                .ToListAsync();

            var grouped = rawData
                .GroupBy(d => new { d.DefectName, d.LineProductionName })
                .ToDictionary(
                    g => new { g.Key.DefectName, g.Key.LineProductionName },
                    g => g.Sum(x => x.DefectQty)
                );

            var colorMap = allDefectTypes.ToDictionary(
                defect => defect,
                _ => $"#{Random.Shared.Next(0x1000000):X6}"
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

            var summaryData = await _context.DefectReports
                .Where(d => d.ReportDate >= DateTime.Today.AddYears(-1))
                .ToListAsync();

            var allCounts = new
            {
                daily = summaryData.Where(d => d.ReportDate.Date == DateTime.Today).Sum(d => d.DefectQty),
                weekly = summaryData.Where(d => d.ReportDate >= DateTime.Today.AddDays(-(int)DateTime.Today.DayOfWeek + (int)DayOfWeek.Monday)).Sum(d => d.DefectQty),
                monthly = summaryData.Where(d => d.ReportDate >= new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1)).Sum(d => d.DefectQty),
                annual = summaryData.Sum(d => d.DefectQty)
            };

            return Ok(new
            {
                labels = allLineProductions,
                datasets,
                daily = allCounts.daily,
                weekly = allCounts.weekly,
                monthly = allCounts.monthly,
                annual = allCounts.annual
            });
        }

        [HttpGet("breakdown")]
        public async Task<IActionResult> GetDefectBreakdown(string lineProduction, string timePeriod = "daily")
        {
            var (startDate, endDate) = GetDateRange(timePeriod);

            var defectsInLine = await _context.DefectReports
                .Include(d => d.LineProduction)
                .Include(d => d.Defect)
                .Where(d => d.ReportDate >= startDate && d.ReportDate <= endDate && d.LineProduction.LineProductionName == lineProduction)
                .GroupBy(d => d.Defect.DefectName)
                .Select(g => new
                {
                    name = g.Key,
                    count = g.Sum(x => x.DefectQty)
                })
                .OrderByDescending(d => d.count)
                .ToListAsync();

            var totalCount = defectsInLine.Sum(d => d.count);

            return Ok(new
            {
                lineProduction,
                defects = defectsInLine,
                totalCount
            });
        }

        [HttpGet("GetTopDefectsAndLines")]
        public async Task<IActionResult> GetTopDefectsAndLines(string timePeriod)
        {
            var (start, end) = GetDateRange(timePeriod);

            var topDefects = await _context.DefectReports
                .Where(d => d.ReportDate >= start && d.ReportDate <= end)
                .GroupBy(d => d.Defect)
                .Select(g => new
                {
                    Name = g.Key.DefectName,
                    Count = g.Sum(x => x.DefectQty)
                })
                .OrderByDescending(x => x.Count)
                .Take(3)
                .ToListAsync();

            var topLines = await _context.DefectReports
                .Where(d => d.ReportDate >= start && d.ReportDate <= end)
                .GroupBy(d => d.LineProduction)
                .Select(g => new
                {
                    Name = g.Key.LineProductionName,
                    Count = g.Sum(x => x.DefectQty)
                })
                .OrderByDescending(x => x.Count)
                .Take(3)
                .ToListAsync();

            return Ok(new { topDefects, topLines });

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
                    WpModel = d.WpModel == null ? null : new { d.WpModel.ModelId, d.WpModel.ModelName },
                    Section = d.Section == null ? null : new { d.Section.SectionId, d.Section.SectionName },
                    LineProduction = d.LineProduction == null ? null : new { d.LineProduction.Id, d.LineProduction.LineProductionName },
                    Defect = d.Defect == null ? null : new { d.Defect.DefectId, d.Defect.DefectName }
                })
                .ToListAsync();

            return Ok(defectReports);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var report = await _context.DefectReports
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
                    WpModel = r.WpModel == null ? null : new { r.WpModel.ModelId, r.WpModel.ModelName },
                    Section = r.Section == null ? null : new { r.Section.SectionId, r.Section.SectionName },
                    LineProduction = r.LineProduction == null ? null : new { r.LineProduction.Id, r.LineProduction.LineProductionName },
                    Defect = r.Defect == null ? null : new { r.Defect.DefectId, r.Defect.DefectName }
                })
                .FirstOrDefaultAsync();

            if (report == null)
                return NotFound();

            return Ok(report);
        }

        public class AddDefectRequest
        {
            public string DefectName { get; set; }
        }

        [HttpPost("add-defect")]
        public async Task<IActionResult> AddDefect([FromBody] AddDefectRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.DefectName))
                return BadRequest("Defect cannot be empty");

            var existingDefect = await _context.Defect
                .FirstOrDefaultAsync(d => d.DefectName.ToLower() == request.DefectName.ToLower());

            if (existingDefect != null)
                return Ok(new { success = true, message = "Defect already exists", defectId = existingDefect.DefectId });

            var newDefect = new Defect { DefectName = request.DefectName };
            _context.Defect.Add(newDefect);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Defect added", defectId = newDefect.DefectId });
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
            existingReport.DefectId = defectReport.DefectId;
            existingReport.LineProductionId = defectReport.LineProductionId;
            existingReport.Description = defectReport.Description;
            existingReport.DefectQty = defectReport.DefectQty;
            existingReport.ModelId = defectReport.ModelId;

            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Report updated successfully" });
        }

        [HttpDelete("delete/{id}")]
        public async Task<IActionResult> DeleteReport(int id)
        {
            var report = await _context.DefectReports.FindAsync(id);
            if (report == null)
                return NotFound();

            _context.DefectReports.Remove(report);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Report deleted successfully" });
        }

        [HttpGet("dropdown")]
        public async Task<IActionResult> GetDropdownData()
        {
            var lineProductions = await _context.LineProductions
                .Select(lp => new { lp.Id, lp.LineProductionName })
                .ToListAsync();

            var sections = await _context.Sections
                .Select(s => new { s.SectionId, s.SectionName })
                .ToListAsync();

            var defects = await _context.Defect
                .Select(d => new { d.DefectId, d.DefectName })
                .ToListAsync();

            var models = await _context.WpModels
                .Select(m => new { m.ModelId, m.ModelName })
                .ToListAsync();

            return Ok(new
            {
                lineProductions,
                sections,
                defects,
                models
            });
        }
    }
}
