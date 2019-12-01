USE AdventureWorks2012
GO

CREATE PROCEDURE dbo.SubCategoriesByColor (
@Colors NVARCHAR(256)
)
AS
BEGIN
  DECLARE @QUERY AS NVARCHAR(MAX)

  SET @QUERY = '
    SELECT Name, ' + @Colors + '
    FROM
    (
      SELECT PSubcat.Name AS Name, Weight, P.Color
      FROM Production.ProductSubcategory AS PSubcat
      JOIN
        Production.Product AS P
        ON PSubcat.ProductSubcategoryID = P.ProductSubcategoryID
    ) AS src
    PIVOT (MAX(Weight) FOR Color IN (' + @Colors + ')) AS piv
  '
  EXEC(@QUERY)
END;


EXECUTE dbo.SubCategoriesByColor '[Red],[Grey],[Blue],[Silver]'
