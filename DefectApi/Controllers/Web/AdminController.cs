using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DefectApi.Models;
using Microsoft.AspNetCore.Authorization;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using System.Linq;

[Authorize(Roles = "admin")]
public class AdminController : Controller
{
    private readonly ApplicationDbContext _context;

    public AdminController(ApplicationDbContext context)
    {
        _context = context;
    }

    public IActionResult Index()
    {
        return View();
    }

    [HttpGet]
    public IActionResult GetData(string type)
    {
        switch (type)
        {
            case "defect":
                return Json(_context.Defect.Select(d => new { id = d.DefectId, defectName = d.DefectName }).ToList());
            case "line":
                return Json(_context.LineProductions.Select(l => new { id = l.Id, lineProductionName = l.LineProductionName }).ToList());
            case "model":
                return Json(_context.WpModels.Select(m => new { id = m.ModelId, modelName = m.ModelName }).ToList());
            default:
                return Json(new { });
        }
    }
    [HttpPost]
    public async Task<IActionResult> AddData([FromBody] AddRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name)) return BadRequest("Name cannot be empty");

        switch (request.Type)
        {
            case "defect":
                _context.Defect.Add(new Defect { DefectName = request.Name });
                break;
            case "line":
                _context.LineProductions.Add(new LineProduction { LineProductionName = request.Name });
                break;
            case "model":
                _context.WpModels.Add(new WpModel { ModelName = request.Name });
                break;
            default:
                return BadRequest("Invalid type");
        }

        await _context.SaveChangesAsync();
        return Ok();
    }

    public class AddRequest
    {
        public string Type { get; set; }
        public string Name { get; set; }
    }


    [HttpPost]
    public async Task<IActionResult> EditData([FromBody] EditRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name)) return BadRequest("Name cannot be empty");

        switch (request.Type)
        {
            case "defect":
                var defect = await _context.Defect.FindAsync(request.Id);
                if (defect == null) return NotFound();
                defect.DefectName = request.Name;
                break;
            case "line":
                var line = await _context.LineProductions.FindAsync(request.Id);
                if (line == null) return NotFound();
                line.LineProductionName = request.Name;
                break;
            case "model":
                var model = await _context.WpModels.FindAsync(request.Id);
                if (model == null) return NotFound();
                model.ModelName = request.Name;
                break;
            default:
                return BadRequest("Invalid type");
        }

        await _context.SaveChangesAsync();
        return Ok();
    }

    public class EditRequest
    {
        public string Type { get; set; }
        public int Id { get; set; }
        public string Name { get; set; }
    }

    [HttpPost]
    public async Task<IActionResult> DeleteData([FromBody] DeleteRequest request)
    {
        switch (request.Type)
        {
            case "defect":
                var defect = await _context.Defect.FindAsync(request.Id);
                if (defect == null) return NotFound();
                _context.Defect.Remove(defect);
                break;
            case "line":
                var line = await _context.LineProductions.FindAsync(request.Id);
                if (line == null) return NotFound();
                _context.LineProductions.Remove(line);
                break;
            case "model":
                var model = await _context.WpModels.FindAsync(request.Id);
                if (model == null) return NotFound();
                _context.WpModels.Remove(model);
                break;
            default:
                return BadRequest("Invalid type");
        }

        await _context.SaveChangesAsync();
        return Ok();
    }

    public class DeleteRequest
    {
        public string Type { get; set; }
        public int Id { get; set; }
    }


    public IActionResult Defect()
    {
        var defects = _context.Defect.ToList();
        return View(defects);
    }

    [HttpPost]
    public IActionResult AddDefect(string defectName)
    {
        if (_context.Defect.Any(d => d.DefectName == defectName))
        {
            ViewBag.Message = "Defect already exists!";
        }
        else
        {
            _context.Defect.Add(new Defect { DefectName = defectName });
            _context.SaveChanges();
            ViewBag.Message = "Defect added successfully!";
        }
        return RedirectToAction("Defect");
    }

    public IActionResult EditDefect(int id)
    {
        var defect = _context.Defect.Find(id);
        return View(defect);
    }

    [HttpPost]
    public IActionResult EditDefect(Defect updated)
    {
        if (_context.Defect.Any(d => d.DefectName == updated.DefectName && d.DefectId != updated.DefectId))
        {
            ViewBag.Message = "Defect name already exists!";
            return View(updated);
        }

        _context.Defect.Update(updated);
        _context.SaveChanges();
        return RedirectToAction("Defect");
    }

    public IActionResult DeleteDefect(int id)
    {
        var defect = _context.Defect.Find(id);
        if (defect != null)
        {
            _context.Defect.Remove(defect);
            _context.SaveChanges();
        }
        return RedirectToAction("Defect");
    }


    public IActionResult LineProduction()
    {
        var lines = _context.LineProductions.ToList();
        return View(lines);
    }

    [HttpPost]
    public IActionResult AddLineProduction(string lineProductionName)
    {
        if (_context.LineProductions.Any(l => l.LineProductionName == lineProductionName))
        {
            ViewBag.Message = "Line production already exists!";
        }
        else
        {
            _context.LineProductions.Add(new LineProduction { LineProductionName = lineProductionName });
            _context.SaveChanges();
            ViewBag.Message = "Line production added!";
        }
        return RedirectToAction("LineProduction");
    }

    public IActionResult EditLineProduction(int id)
    {
        var line = _context.LineProductions.Find(id);
        return View(line);
    }

    [HttpPost]
    public IActionResult EditLineProduction(LineProduction updated)
    {
        if (_context.LineProductions.Any(l => l.LineProductionName == updated.LineProductionName && l.Id != updated.Id))
        {
            ViewBag.Message = "Line name already exists!";
            return View(updated);
        }

        _context.LineProductions.Update(updated);
        _context.SaveChanges();
        return RedirectToAction("LineProduction");
    }

    public IActionResult DeleteLineProduction(int id)
    {
        var line = _context.LineProductions.Find(id);
        if (line != null)
        {
            _context.LineProductions.Remove(line);
            _context.SaveChanges();
        }
        return RedirectToAction("LineProduction");
    }


    public IActionResult WpModel()
    {
        var models = _context.WpModels.ToList();
        return View(models);
    }

    [HttpPost]
    public IActionResult AddWpModel(string modelName)
    {
        if (_context.WpModels.Any(m => m.ModelName == modelName))
        {
            ViewBag.Message = "Model already exists!";
        }
        else
        {
            _context.WpModels.Add(new WpModel { ModelName = modelName });
            _context.SaveChanges();
            ViewBag.Message = "Model added!";
        }
        return RedirectToAction("WpModel");
    }

    public IActionResult EditWpModel(int id)
    {
        var model = _context.WpModels.Find(id);
        return View(model);
    }

    [HttpPost]
    public IActionResult EditWpModel(WpModel updated)
    {
        if (_context.WpModels.Any(m => m.ModelName == updated.ModelName && m.ModelId != updated.ModelId))
        {
            ViewBag.Message = "Model name already exists!";
            return View(updated);
        }

        _context.WpModels.Update(updated);
        _context.SaveChanges();
        return RedirectToAction("WpModel");
    }

    public IActionResult DeleteWpModel(int id)
    {
        var model = _context.WpModels.Find(id);
        if (model != null)
        {
            _context.WpModels.Remove(model);
            _context.SaveChanges();
        }
        return RedirectToAction("WpModel");
    }
}
