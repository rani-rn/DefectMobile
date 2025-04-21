using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace DefectRecord.Models{
public class ApplicationDbContext : DbContext {
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
    : base(options)
    {
    }
    public DbSet<Defect> Defect {get; set;}
    public DbSet<DefectReport> DefectReports {get;set;}
    public DbSet<LineProduction> LineProductions {get; set;}
    public DbSet<Section> Sections {get; set;}
    }
}