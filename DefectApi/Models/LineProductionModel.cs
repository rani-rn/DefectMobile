using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
public class LineProduction {
    [Key]
    public int Id { get; set; }
    public string LineProductionName {get; set;}
    
}