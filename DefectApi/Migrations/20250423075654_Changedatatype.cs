using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DefectApi.Migrations
{
    /// <inheritdoc />
    public partial class Changedatatype : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "LineProductions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    LineProductionName = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LineProductions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Sections",
                columns: table => new
                {
                    SectionId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SectionName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    SectionTotal = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Sections", x => x.SectionId);
                });

            migrationBuilder.CreateTable(
                name: "Defect",
                columns: table => new
                {
                    DefectId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DefectName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    SectionId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Defect", x => x.DefectId);
                    table.ForeignKey(
                        name: "FK_Defect_Sections_SectionId",
                        column: x => x.SectionId,
                        principalTable: "Sections",
                        principalColumn: "SectionId");
                });

            migrationBuilder.CreateTable(
                name: "DefectReports",
                columns: table => new
                {
                    ReportId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ReportDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Reporter = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DefectQty = table.Column<int>(type: "int", nullable: false),
                    ProdQty = table.Column<int>(type: "int", nullable: false),
                    SectionId = table.Column<int>(type: "int", nullable: false),
                    LineProductionId = table.Column<int>(type: "int", nullable: false),
                    DefectId = table.Column<int>(type: "int", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DefectNew = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DefectReports", x => x.ReportId);
                    table.ForeignKey(
                        name: "FK_DefectReports_Defect_DefectId",
                        column: x => x.DefectId,
                        principalTable: "Defect",
                        principalColumn: "DefectId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_DefectReports_LineProductions_LineProductionId",
                        column: x => x.LineProductionId,
                        principalTable: "LineProductions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_DefectReports_Sections_SectionId",
                        column: x => x.SectionId,
                        principalTable: "Sections",
                        principalColumn: "SectionId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Defect_SectionId",
                table: "Defect",
                column: "SectionId");

            migrationBuilder.CreateIndex(
                name: "IX_DefectReports_DefectId",
                table: "DefectReports",
                column: "DefectId");

            migrationBuilder.CreateIndex(
                name: "IX_DefectReports_LineProductionId",
                table: "DefectReports",
                column: "LineProductionId");

            migrationBuilder.CreateIndex(
                name: "IX_DefectReports_SectionId",
                table: "DefectReports",
                column: "SectionId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "DefectReports");

            migrationBuilder.DropTable(
                name: "Defect");

            migrationBuilder.DropTable(
                name: "LineProductions");

            migrationBuilder.DropTable(
                name: "Sections");
        }
    }
}
