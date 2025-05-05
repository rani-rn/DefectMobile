using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace DefectApi.Models
{
    public class ApplicationDbContext : DbContext
    {
     
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
        {
        }
        public DbSet<User> Users { get; set; }
        public DbSet<Defect> Defect { get; set; }
        public DbSet<DefectReport> DefectReports { get; set; }
        public DbSet<LineProduction> LineProductions { get; set; }
        public DbSet<Section> Sections { get; set; }

        public DbSet<WpModel> WpModels { get; set; }


    }


}