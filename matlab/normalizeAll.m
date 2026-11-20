%% Robust PET normalization batch

% Set paths
pet_folder = ' '; % path to the folder containing the .nii files
fdg_template = ' '; % path to the [18f]fdg.nii template file

% Initialize SPM
spm('defaults','PET');
spm_jobman('initcfg');

% Get all PET files in folder
pet_files = spm_select('FPList', pet_folder, '\.nii$');

for i = 1:size(pet_files,1)
    source_image = strtrim(pet_files(i,:));
    fprintf('Processing: %s\n', source_image);

    % --- Step 0: Check affine determinant ---
    V = spm_vol(source_image);
    det_aff = det(V.mat(1:3,1:3));
    if det_aff < 0
        fprintf('  Warning: negative determinant (possible L-R flip): %.3f\n', det_aff);
    end

    % --- Step 1: Optional manual origin check ---
    spm_check_registration(source_image);
    fprintf('  Check/set origin near AC and close display window to continue...\n');
    pause; % wait for user to set origin manually

    % --- Step 2: Rigid-body coregistration to FDG template ---
    clear matlabbatch;
    matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {fdg_template};
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = {source_image};
    matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = ...
        [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 1;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
    spm_jobman('run', matlabbatch);

    % Update path to coregistered image
    [pathstr, name, ext] = fileparts(source_image);
    coreg_image = fullfile(pathstr, ['r' name ext]);

    % --- Step 3: Nonlinear normalization (estwrite) ---
    clear matlabbatch;
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {coreg_image};
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {coreg_image};
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = {fdg_template};
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = 1;

    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -70; 78 76 85];
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = [2 2 2];
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp = 1; % trilinear
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';

    spm_jobman('run', matlabbatch);

    fprintf('  Done: %s -> w%s\n', coreg_image, ['r' name ext]);
end

fprintf('All PETs processed.\n');
