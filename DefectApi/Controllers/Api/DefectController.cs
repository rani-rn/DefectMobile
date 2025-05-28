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
            DateTime start, end;

            switch (timePeriod.ToLower())
            {
                case "daily":
                case "today":
                    int daysSinceMonday = ((int)today.DayOfWeek + 6) % 7;
                    start = today.AddDays(-daysSinceMonday);

                    end = today.AddDays(1).AddTicks(-1);

                    if (today.DayOfWeek == DayOfWeek.Friday || today.DayOfWeek == DayOfWeek.Saturday || today.DayOfWeek == DayOfWeek.Sunday)
                    {
                        int daysSinceThursday = ((int)today.DayOfWeek + 3) % 7;
                        end = today.AddDays(-daysSinceThursday).Date.AddDays(1).AddTicks(-1);
                    }
                    break;


                case "weekly":
                    start = new DateTime(today.Year, today.Month, 1);
                    end = today.AddDays(1).AddTicks(-1);
                    break;


                case "monthly":
                    start = new DateTime(today.Year, 1, 1);
                    end = today.AddDays(1).AddTicks(-1);
                    break;


                default:
                    start = today;
                    end = today.AddDays(1).AddTicks(-1);
                    break;
            }
            return (start, end);
        }

        [HttpGet("chart")]
        public async Task<IActionResult> GetChartData(string timePeriod = "today")
        {
            var (startDate, endDate) = GetDateRange(timePeriod);

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

       .Select(d => new
       {
           d.ReportDate,
           LineProductionName = d.LineProduction.LineProductionName,
           d.DefectQty
       })
       .ToListAsync();
            List<string> labels;
            Dictionary<string, Dictionary<string, int>> groupedData = new();

            if (timePeriod == "daily" || timePeriod == "today")
            {
                labels = new List<string> { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" };

                foreach (var label in labels)
                {
                    groupedData[label] = allLineProductions.ToDictionary(lp => lp, _ => 0);
                }

                foreach (var data in rawData)
                {
                    var day = data.ReportDate.DayOfWeek.ToString();
                    if (!groupedData.ContainsKey(day))
                        continue;
                    groupedData[day][data.LineProductionName] += data.DefectQty;
                }
            }
            else if (timePeriod == "weekly")
            {
                labels = new List<string> { "Week 1", "Week 2", "Week 3", "Week 4" };

                foreach (var label in labels)
                {
                    groupedData[label] = allLineProductions.ToDictionary(lp => lp, _ => 0);
                }

                foreach (var data in rawData)
                {
                    var weekNum = (int)Math.Ceiling(data.ReportDate.Day / 7.0);
                    var label = $"Week {weekNum}";
                    if (!groupedData.ContainsKey(label))
                        continue;
                    groupedData[label][data.LineProductionName] += data.DefectQty;
                }
            }
            else if (timePeriod == "monthly")
            {
                labels = System.Globalization.CultureInfo.CurrentCulture.DateTimeFormat.MonthNames
                    .Where(m => !string.IsNullOrWhiteSpace(m))
                    .ToList();

                foreach (var label in labels)
                {
                    groupedData[label] = allLineProductions.ToDictionary(lp => lp, _ => 0);
                }

                foreach (var data in rawData)
                {
                    var label = data.ReportDate.ToString("MMMM");
                    if (!groupedData.ContainsKey(label))
                        continue;
                    groupedData[label][data.LineProductionName] += data.DefectQty;
                }
            }
            else
            {
                return BadRequest("Invalid timePeriod.");
            }


            var datasets = allLineProductions.Select(lp => new
            {
                label = lp,
                data = labels.Select(label => groupedData[label].ContainsKey(lp) ? groupedData[label][lp] : 0).ToList(),
                backgroundColor = $"#{Random.Shared.Next(0x1000000):X6}"
            });

            var summaryStartOfWeek = DateTime.Today.AddDays(-(int)DateTime.Today.DayOfWeek + (int)DayOfWeek.Monday);
            var summaryStartOfMonth = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);

            var summaryData = await _context.DefectReports
                .Where(d => d.ReportDate >= summaryStartOfMonth)
                .ToListAsync();

            var summary = new
            {
                today = summaryData
                    .Where(d => d.ReportDate.Date == DateTime.Today)
                    .Sum(d => d.DefectQty),
                week = summaryData
                    .Where(d => d.ReportDate >= summaryStartOfWeek)
                    .Sum(d => d.DefectQty),
                month = summaryData
                    .Sum(d => d.DefectQty)
            };

            return Ok(new
            {
                labels,
                datasets,
                summary
            });

        }

        [HttpGet("chart-breakdown")]
        public async Task<IActionResult> GetBreakdown(
 string timePeriod,
 string label,
 string lineProductionName)
        {
            var (startDate, endDate) = GetDateRange(timePeriod);

            var query = _context.DefectReports
                .Include(d => d.Defect)
                .Include(d => d.LineProduction)
                .Where(d => d.ReportDate >= startDate && d.ReportDate <= endDate);

            if (!string.IsNullOrEmpty(lineProductionName))
            {
                query = query.Where(d => d.LineProduction.LineProductionName == lineProductionName);
            }

            if (timePeriod == "daily" || timePeriod == "today")
            {
                var dayIndex = Array.IndexOf(new[] { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" }, label);
                if (dayIndex >= 0)
                {
                    var targetDate = startDate.AddDays(dayIndex);
                    query = query.Where(d => d.ReportDate.Date == targetDate.Date);
                }
            }
            else if (timePeriod == "weekly")
            {
                var weekNum = int.Parse(label.Replace("Week ", ""));
                var firstDayOfMonth = new DateTime(startDate.Year, startDate.Month, 1);
                var firstMonday = firstDayOfMonth.AddDays(((int)DayOfWeek.Monday - (int)firstDayOfMonth.DayOfWeek + 7) % 7);
                var startOfWeek = firstMonday.AddDays((weekNum - 1) * 7);
                var endOfWeek = startOfWeek.AddDays(6);
                query = query.Where(d => d.ReportDate >= startOfWeek && d.ReportDate <= endOfWeek);
            }
            else if (timePeriod == "monthly")
            {
                var month = DateTime.ParseExact(label, "MMMM", null).Month;
                query = query.Where(d => d.ReportDate.Month == month);
            }

            var breakdownData = await query
                .GroupBy(d => d.Defect.DefectName)
                .Select(g => new
                {
                    Defect = g.Key,
                    TotalQty = g.Sum(x => x.DefectQty)
                })
                .OrderByDescending(x => x.TotalQty)
                .ToListAsync();

            return Ok(breakdownData);
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
