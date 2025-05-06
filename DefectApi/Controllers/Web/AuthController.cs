using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DefectApi.Models;
using DefectApi.Dto;

namespace DefectApi.Controllers.Web
{
    public class AuthController : Controller
    {
        private readonly ApplicationDbContext _context;
        public AuthController(ApplicationDbContext context) => _context = context;

        public IActionResult Register() => View();

        [HttpPost]
        public async Task<IActionResult> Register(RegisterDto dto)
        {
            var userExist = await _context.Users.AnyAsync(u => u.Email == dto.Email);
            if (userExist)
            {
                ModelState.AddModelError("", "Email sudah terdaftar");
                return View(dto);
            }

            var user = new User
            {
                Name = dto.Name,
                Email = dto.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                Role = dto.Role
            };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();
            TempData["Success"] = "Registrasi berhasil. Silakan login";
            return RedirectToAction("Login");
        }

        public IActionResult Login() => View();

        [HttpPost]
        public async Task<IActionResult> Login(LoginDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
            {
                ModelState.AddModelError("", "Email atau password salah");
                return View(dto);
            }

            HttpContext.Session.SetString("Name", user.Name);
            HttpContext.Session.SetString("Email", user.Email);
            HttpContext.Session.SetString("Role", user.Role);

            return RedirectToAction("Index", "Home");
        }

        public IActionResult Logout()
        {
            HttpContext.Session.Clear();
            return RedirectToAction("Login");
        }
    }
}