using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class Defect {
    [Key]
    public int DefectId { get; set; }
    public string DefectName {get; set;}

    public int? SectionId {get; set;}

    
    [ForeignKey("SectionId")]
    public Section Section { get; set; }

}