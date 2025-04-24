using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

public class WpModel
{
    [Key]
    public int ModelId { get; set; }
    public string ModelName { get; set; }

}