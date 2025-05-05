using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DefectApi.Models;
using System.Threading.Tasks;
using BCrypt.Net;

namespace DefectApi.Controllers
{
    [Route("[controller]/[action]")]
    public class ProfileController : Controller
    {
        private readonly ApplicationDbContext _context;
        public ProfileController(ApplicationDbContext context) => _context = context;

        public IActionResult Index()
        {
            var name = HttpContext.Session.GetString("Name");
            var email = HttpContext.Session.GetString("Email");
            var role = HttpContext.Session.GetString("Role");

            if (string.IsNullOrEmpty(name))
                return RedirectToAction("Login", "Auth");

            ViewBag.Name = name;
            ViewBag.Email = email;
            ViewBag.Role = role;

            return View();
        }

        public IActionResult ChangePassword()
        {
            var email = HttpContext.Session.GetString("Email");
            if (string.IsNullOrEmpty(email))
                return RedirectToAction("Login", "Auth");

            return View();
        }

        [HttpPost]
        public async Task<IActionResult> ChangePassword(string currentPassword, string newPassword, string confirmPassword)
        {
            var email = HttpContext.Session.GetString("Email");
            if (string.IsNullOrEmpty(email))
                return RedirectToAction("Login", "Auth");

            if (newPassword != confirmPassword)
            {
                ModelState.AddModelError("", "New password and confirm password do not match");
                return View();
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user == null || !BCrypt.Net.BCrypt.Verify(currentPassword, user.PasswordHash))
            {
                ModelState.AddModelError("", "Current password is incorrect");
                return View();
            }

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
            await _context.SaveChangesAsync();

            TempData["Success"] = "Password updated successfully";
            return RedirectToAction("Index");
        }
    }
}
