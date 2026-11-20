% Initialize SPM
spm('defaults', 'PET');
spm_jobman('initcfg');

% Reference image (atlas)
ref_image = ' '; % path to the AAL3v1.nii file

% Folder containing normalized PET images
pet_folder = ' '; % path to normalized .nii files (wrX.nii)

% File sequence (wr1.nii to wr31.nii)
for i = 1:31
    source_image = fullfile(pet_folder, ['wr' num2str(i) '.nii']);
    
    if ~isfile(source_image)
        fprintf('File does not exist, skipping: %s\n', source_image);
        continue;
    end
    
    % Reslice the source image
    spm_reslice({ref_image; source_image}, struct( ...
        'interp', 4, ...       % Interpolation (4 = 4th-degree B-spline)
        'wrap', [0 0 0], ...
        'mask', 0, ...
        'which', 1, ...        % Reslice only the source image
        'mean', 0));           % Do not create a mean image
    
    fprintf('Resliced %s\n', source_image);
end
