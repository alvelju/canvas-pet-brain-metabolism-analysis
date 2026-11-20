% --- CONFIG ---
pet_folder = ' '; % path to normalized and resliced files (rwrX.nii)
atlas_file = ' '; % path to the AAL3v1.nii file
atlas_txt  = ' '; % path to the AAL3v1.nii.txt file
output_excel = 'glucosa_por_region_todos.xlsx';

% --- 1. Load atlas ---
atlas_vol = spm_vol(atlas_file);
atlas_data = spm_read_vols(atlas_vol);

region_ids = unique(atlas_data(:));
region_ids(region_ids == 0) = [];  % remove background

% --- 2. Read region names from the text file ---
fid = fopen(atlas_txt, 'r');
data = textscan(fid, '%d %s %d', 'Delimiter', ' ', 'MultipleDelimsAsOne', 1);
fclose(fid);

region_ids_txt = data{1};
region_names = data{2};
id2name_map = containers.Map(region_ids_txt, region_names);

% --- 3. Create the initial table ---
num_regions = length(region_ids);
region_names_result = cell(num_regions,1);
for i = 1:num_regions
    id = region_ids(i);
    if isKey(id2name_map, id)
        region_names_result{i} = id2name_map(id);
    else
        region_names_result{i} = 'Unknown';
    end
end
results_table = table(region_ids, region_names_result, ...
                      'VariableNames', {'Region_ID','Region_Name'});

% --- 4. Loop through all PET images ---
for i = 1:31
    pet_file = fullfile(pet_folder, ['rwr' num2str(i) '.nii']);
    
    if ~isfile(pet_file)
        fprintf('Skipping (not found): %s\n', pet_file);
        continue;
    end
    
    fprintf('Processing: %s\n', pet_file);
    
    % Load PET image
    pet_vol = spm_vol(pet_file);
    pet_data = spm_read_vols(pet_vol);
    
    % Calculate regional means
    mean_values = zeros(num_regions,1);
    for r = 1:num_regions
        mask = (atlas_data == region_ids(r));
        values = pet_data(mask);
        values = values(~isnan(values));
        mean_values(r) = mean(values);
    end
    
    % Add a column named "Subj_i"
    col_name = sprintf('Subj_%d', i);
    results_table.(col_name) = mean_values;
end

% --- 5. Save to Excel ---
writetable(results_table, output_excel);
fprintf('✅ Results saved to %s\n', output_excel);
