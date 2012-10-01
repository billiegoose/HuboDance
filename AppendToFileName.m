function result = AppendToFileName(filename, suffix)
[pathstr, name, ext] = fileparts(filename);
if isempty(pathstr) 
    result = [name suffix ext];
else
    result = [pathstr filesep name suffix ext];
end