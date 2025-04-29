using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;
using DefectApi.Models;

namespace DefectApi.Controllers
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
        public IActionResult GetChartData(int? defectId = null, string timePeriod = "daily")
        {
            var today = DateTime.Today;
            DateTime startDate = today;
            var startOfWeek = today.AddDays(-(int)today.DayOfWeek + (int)DayOfWeek.Monday);
            var startOfMonth = new DateTime(today.Year, today.Month, 1);
            var startOfYear = new DateTime(today.Year, 1, 1);

            var dailyCount = _context.DefectReports
    .Where(d => d.ReportDate.Date == today)
    .Sum(d => (int?)d.DefectQty) ?? 0;

            var weeklyCount = _context.DefectReports
                .Where(d => d.ReportDate >= startOfWeek)
                .Sum(d => (int?)d.DefectQty) ?? 0;

            var monthlyCount = _context.DefectReports
                .Where(d => d.ReportDate >= startOfMonth)
                .Sum(d => (int?)d.DefectQty) ?? 0;

            var annualCount = _context.DefectReports
                .Where(d => d.ReportDate >= startOfYear)
                .Sum(d => (int?)d.DefectQty) ?? 0;

            switch (timePeriod.ToLower())
            {
                case "weekly":
                    int diff = (7 + (today.DayOfWeek - DayOfWeek.Monday)) % 7;
                    startDate = today.AddDays(-1 * diff);
                    break;
                case "monthly":
                    startDate = new DateTime(today.Year, today.Month, 1);
                    break;
                case "annual":
                    startDate = new DateTime(today.Year, 1, 1);
                    break;
                default:
                    startDate = today;
                    break;
            }

            var query = _context.DefectReports
                .Include(d => d.LineProduction)
                .Where(d =>
                    (!defectId.HasValue || d.DefectId == defectId) &&
                    d.ReportDate >= startDate
                );

            var chartData = query
                .GroupBy(d => new { d.LineProductionId, d.LineProduction.LineProductionName })
                .Select(g => new
                {
                    label = g.Key.LineProductionName,
                    value = g.Sum(d => d.DefectQty)
                })
                .ToList();

            var total = query.Count();

            return Ok(new
            {
                chartData,
                total,
                daily = dailyCount,
                weekly = weeklyCount,
                monthly = monthlyCount,
                annual = annualCount
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
