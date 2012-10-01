function ConvertJaemiToHuboPlus(inputFile)
outputFile = AppendToFileName(inputFile, '_HuboPlus');

% Array :  1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21
% Joints: WST LHY LHR LHP LKN LAP LAR RHY RHR RHP RKN RAP RAR LSP LSR LSY LEB RSP RSR RSY REB
joints = [ 5, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,  9, 10, 11, 12, 16, 17, 18, 19];
reverseIndex = [1,14,15,16,17,18,19,21];

% Iterate through the file
file = fopen(inputFile);
data1 = fscanf(file,'%f');
fclose(file);
rows = floor(length(data1)/numel(joints));
data = data1(1:rows*numel(joints));
data = reshape(data,numel(joints),rows)';

for i = 1:length(reverseIndex)
    data(:,reverseIndex(i)) = - data(:,reverseIndex(i));
end

% % Interpolate to 100Hz
% t1 = linspace(0,1,rows);
% t2 = linspace(0,1,rows*10);
% interpolatedData = interp1(t1,data,t2);
file = fopen(outputFile,'wt');
for i=1:rows
    fprintf(file,'%2.1f ',data(i,:));
    fprintf(file,'\n');
end
fclose(file);