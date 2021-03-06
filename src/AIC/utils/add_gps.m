clear
clc

opts = get_opts_aic();
for scene = 1:5
gt = 0;

cam_pool = opts.cams_in_scene{scene};
all_detections = cell(1,length(cam_pool));

for i = length(cam_pool):-1:1
    iCam = cam_pool(i);
    opts.current_camera = iCam;
    % Load OpenPose detections for current camera
    if gt
        data = load(sprintf('%s/%s/S%02d/c%03d/gt/gt.txt', opts.dataset_path, opts.folder_by_scene{scene}, scene, iCam));
    else
        data = load(sprintf('%s/%s/S%02d/c%03d/det/det_%s.txt', opts.dataset_path, opts.folder_by_scene{scene}, scene, iCam, opts.detections));
    end
    bboxs = data(:,3:6);
    % feet pos
    feet_pos = feetPosition(bboxs);
    
    % Show window detections
    if opts.visualize
    startFrame = 100;
    detectionCenters = feet_pos((data(:,1) >= startFrame) & (data(:,1) <= (startFrame+opts.tracklets.window_width)),:);
    spatialGroupIDs = ones(length(detectionCenters),1);
    trackletsVisualizePart1;
    end
    
    % image2gps
    gps_pos = image2gps(opts,feet_pos,scene,iCam);
    re_image_pos = gps2image(opts,gps_pos,scene,iCam);
    max(max(feet_pos-re_image_pos))
    
    % global time
    frame_offset = opts.frame_offset{scene} .* opts.fps;
    global_frame = local2global(frame_offset(iCam),data(:,1));
    
    data(:,8) = ones(size(global_frame))*iCam;
    data(:,9) = global_frame;
    data(:,10:11) = gps_pos;
    all_detections{iCam} = data;
    if gt
        dlmwrite(sprintf('%s/%s/S%02d/c%03d/gt/gt_gps.txt', opts.dataset_path, opts.folder_by_scene{scene}, scene, iCam),data,'precision',10);
    else
        dlmwrite(sprintf('%s/%s/S%02d/c%03d/det/det_%s_gps.txt', opts.dataset_path, opts.folder_by_scene{scene}, scene, iCam, opts.detections),data,'precision',10);
    end
end
end
