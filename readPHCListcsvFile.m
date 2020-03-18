clear all; clc
phcNameData = readtable ('d:\Downloads\24x7_phc_tamilnadu.csv');

phcTable = cell2table(cell(0,6));
phcTable.Properties.VariableNames{'Var1'}='SerialNumber';
phcTable.Properties.VariableNames{'Var2'}='RevenueDistrict';
phcTable.Properties.VariableNames{'Var3'}='HealthDistrict';
phcTable.Properties.VariableNames{'Var4'}='HealthBlock';
phcTable.Properties.VariableNames{'Var5'}='PHC_Name';
phcTable.Properties.VariableNames{'Var6'}='googleSearchPhrase';

phcTableWithErrors = phcTable;

%% Only lines from data
for iRows = 1:size (phcNameData, 1)
  rowValue = phcNameData(iRows, 1);
  rowValue = cell2mat(rowValue{1,1});
  %fprintf ('%s\n', rowValue)
  % get first token
  [firstToken, remainingText] = strtok (rowValue, ' ');
  %fprintf ('%s\n', firstToken)
  
  % check if first token is purely a number
  serialNumber = str2num(firstToken);
  if (~isnan (serialNumber))
    %fprintf ('Serial Number is %d\n', serialNumber)
    %phcTable  = cell2table(cell(0,4), VariableNames, {'RevenueDistrict','HealthDistrict','HealthBlock','PHC_Name'});
    [revenueDistrict, remainingText] = strtok (remainingText);
    if (strcmp (revenueDistrict, 'THE'))
      [revenueDistrict2, remainingText] = strtok (remainingText);
      revenueDistrict = [revenueDistrict ' ' revenueDistrict2];
    end
    [healthDistrict, remainingText] = strtok (remainingText);
    if (strcmp (healthDistrict, 'THE'))
      [healthDistrict2, remainingText] = strtok (remainingText);
      healthDistrict = [healthDistrict ' ' healthDistrict2];
    end
    patternsWithTwoWordsInHealthBlock = ["EAST", "WEST", "NORTH", "SOUTH", "HILLS", "MOUNT"];
    if (contains(remainingText, patternsWithTwoWordsInHealthBlock))
      [healthBlock1, remainingText] = strtok (remainingText);
      [healthBlock2, remainingText] = strtok (remainingText);
      healthBlock = [healthBlock1 ' ' healthBlock2];      
    else
      [healthBlock, remainingText] = strtok (remainingText);
    end
    [phcName, remainingText] = strtok (remainingText);
    if (strlength (remainingText) > 0)
      %fprintf ('Parsing error in line %d\n', serialNumber)
      phcName = [phcName remainingText];
      googleSearchPhrase = sprintf ('%s PHC, %s, %s', phcName, healthBlock, healthDistrict);
      phcRowData = {serialNumber, revenueDistrict, healthDistrict, healthBlock, phcName, googleSearchPhrase};
      phcTableWithErrors = [phcTableWithErrors; phcRowData];
    else
      googleSearchPhrase = sprintf ('%s Primary Health Center, %s, %s District', phcName, healthDistrict, revenueDistrict);
      phcRowData = {serialNumber, revenueDistrict, healthDistrict, healthBlock, phcName, googleSearchPhrase};
      phcTable = [phcTable; phcRowData];
    end
  else
    %fprintf ('Serial Number is not a number\n')
  end
end

writetable (phcTable, 'd:\Downloads\PHC_tableCorrected.xls');