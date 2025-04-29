using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ClosedXML.Excel;
using DefectApi.Models;

namespace DefectApi.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    private readonly ApplicationDbContext _context;

    public HomeController(ILogger<HomeController> logger, ApplicationDbContext context)
    {
        _logger = logger;
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> Input()
    {
        await LoadViewBagData();
        return View();
    }
    [HttpGet]
    public async Task<IActionResult> Update(int id)
    {
        var defectReport = await _context.DefectReports
            .Include(d => d.Defect)
            .Include(d => d.LineProduction)
            .Include(d => d.Section)
            .FirstOrDefaultAsync(d => d.ReportId == id);

        if (defectReport == null)
        {
            return NotFound();
        }

        await LoadViewBagData();
        return View(defectReport);
    }

    public IActionResult Index()
    {
        return View();
    }

    public IActionResult Record()
    {
        var defectReports = _context.DefectReports
                            .Include(d => d.Defect)
                            .Include(d => d.WpModel)
                            .Include(d => d.LineProduction)
                            .Include(d => d.Section)
                            .ToList();
        return View(defectReports);
    }

    public IActionResult ExportToExcel()
    {
        var data = _context.DefectReports
    .Include(d => d.Defect)
    .Include(d => d.WpModel)
    .Include(d => d.LineProduction)
    .Include(d => d.Section)
    .ToList()
    .Select(d => new
    {
        No = d.ReportId,
        Date = d.ReportDate,
        Reporter = d.Reporter,
        Model = d.WpModel != null ? d.WpModel.ModelName : null,
        Section = d.Section != null ? d.Section.SectionName : null,
        LineProduction = d.LineProduction != null ? d.LineProduction.LineProductionName : null,
        LineProdQty = d.LineProdQty,
        Defect = d.Defect != null ? d.Defect.DefectName : null,
        Description = d.Description,
        DefectQty = d.DefectQty
    })
    .ToList();


        using (var workbook = new XLWorkbook())
        {
            var worksheet = workbook.Worksheets.Add("Defect Reports");

            worksheet.Cell(1, 1).Value = "No";
            worksheet.Cell(1, 2).Value = "Date";
            worksheet.Cell(1, 3).Value = "Reporter";
            worksheet.Cell(1, 4).Value = "Model";
            worksheet.Cell(1, 5).Value = "Section";
            worksheet.Cell(1, 6).Value = "Line Production";
            worksheet.Cell(1, 7).Value = "Line Prod Qty";
            worksheet.Cell(1, 8).Value = "Defect";
            worksheet.Cell(1, 9).Value = "Description";
            worksheet.Cell(1, 10).Value = "Defect Qty";

            for (int i = 0; i < data.Count; i++)
            {
                var item = data[i];
                worksheet.Cell(i + 2, 1).Value = item.No;
                worksheet.Cell(i + 2, 2).Value = item.Date.ToString("yyyy-MM-dd");
                worksheet.Cell(i + 2, 3).Value = item.Reporter;
                worksheet.Cell(i + 2, 4).Value = item.Model;
                worksheet.Cell(i + 2, 5).Value = item.Section;
                worksheet.Cell(i + 2, 6).Value = item.LineProduction;
                worksheet.Cell(i + 2, 7).Value = item.LineProdQty;
                worksheet.Cell(i + 2, 8).Value = item.Defect;
                worksheet.Cell(i + 2, 9).Value = item.Description;
                worksheet.Cell(i + 2, 10).Value = item.DefectQty;
            }

            using (var stream = new MemoryStream())
            {
                workbook.SaveAs(stream);
                var content = stream.ToArray();
                return File(content, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "DefectReport.xlsx");
            }
        }
    }

    private async Task LoadViewBagData()
    {
        ViewBag.Sections = await _context.Sections
            .Select(s => new { s.SectionId, s.SectionName })
            .ToListAsync();

        ViewBag.Defects = await _context.Defect
            .Select(d => new { d.DefectId, d.DefectName })
            .ToListAsync();

        ViewBag.LineProductions = await _context.LineProductions
            .Select(lp => new { lp.Id, lp.LineProductionName })
            .ToListAsync();

        ViewBag.WpModels = await _context.WpModels
            .Select(wm => new { wm.ModelId, wm.ModelName })
            .ToListAsync();
    }
    public async Task<IActionResult> GetPaginatedReports(int page = 1, int pageSize = 10)
    {
        var defectReports = await _context.DefectReports
            .Include(d => d.Defect)
            .Include(d => d.LineProduction)
            .Include(d => d.Section)
            .Include(d => d.WpModel)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
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

        var totalReports = await _context.DefectReports.CountAsync();

        return Ok(new
        {
            defectReports,
            totalReports
        });
    }



    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
