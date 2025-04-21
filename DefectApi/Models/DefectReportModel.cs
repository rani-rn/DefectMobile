using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class DefectReport {
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)] 
    public int ReportId { get; set; }
    
  
    public DateTime ReportDate { get; set; }
    [Required]
    public string Reporter {get; set;}

    public int DefectQty {get; set;}

    public int ProdQty {get; set;}
    [Required]
    public int SectionId { get; set; }
    
    [Required]
    public int LineProductionId {get; set;}
        
    [Required]
    public int DefectId {get;  set;}
    
    public string? Description {get; set;}
    [Required]
    public string Status {get; set;}
  

     [ForeignKey("LineProductionId")]
    public LineProduction LineProduction { get; set; }

    [ForeignKey("DefectId")]
    public Defect Defect { get; set; }

    [ForeignKey("SectionId")]
    public Section Section { get; set; }
}