-- Original SQL function
-- This function merges two tables
CREATE FUNCTION tabla_fusion(tabla1 TEXT, tabla2 TEXT)
RETURNS TABLE(column1 TYPE, column2 TYPE) AS $$
BEGIN
    -- Logic to merge tables
END;
$$ LANGUAGE plpgsql;