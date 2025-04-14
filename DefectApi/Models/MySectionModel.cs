using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class Section {
    [Key]
    public int SectionId { get; set; }
    public string SectionName {get; set;}
    public int SectionTotal {get; set;}
}