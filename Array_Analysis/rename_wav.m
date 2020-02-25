% Provide species name abbreviation, if different from first 2 letters of file name:
spec = 'Gg';
hp = 'HP5';

% Select folder containing wav files to be renamed
str1 = 'Select Directory containing .wav files';
indir = 'H:\Melissa_array_data';
matDir = uigetdir(indir,str1);

cd(matDir);

% Get all wav files in the current folder
files = dir('*.wav');

% Loop through each
for id = 1:length(files)
    % Get the file name (minus the extension)
    [~, f,~] = fileparts(files(id).name);
    % Get species abbreviation, if not already specified above
    if isempty(spec)
      spec = f(1:2);each 
    end
    % Extract date/time from file name
      time = f((end-9):(end-4));
      d1 = f((end-18):(end-11));
%       d2 = '13';
%       d3 = f(9:12);
%       date = horzcat(d1,d2,d3);
      
    % Rename file
      if ~isnan(date)
          % If numeric, rename
        movefile(files(id).name, sprintf('%1$s_%2$s_%3$s_%4$s.wav', spec,hp,d1,time));
      end
end