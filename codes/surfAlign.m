function [recovered,qual] = surfAlign(ref,moving,nonrigid,disp)
if nargin<4
    disp = false;
end
if nargin<3
    disp = false;
    nonrigid = false;
end
ref = rgb2gray(ref);
%     ref = imbinarize(ref);
BW = rgb2gray(moving);
%     BW = imbinarize(BW);
%     imshow(BW)

ptsOriginal  = detectSURFFeatures(ref);
ptsDistorted = detectSURFFeatures(BW);
[featuresOriginal,  validPtsOriginal]  = extractFeatures(ref,  ptsOriginal);
[featuresDistorted, validPtsDistorted] = extractFeatures(BW, ptsDistorted);
[indexPairs,qual] = matchFeatures(featuresOriginal, featuresDistorted,...
    'MatchThreshold',70);
matchedOriginal  = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));
tform = estimateGeometricTransform(...
    matchedDistorted, matchedOriginal, 'affine');

outputView = imref2d(size(ref));
recovered  = imwarp(moving,tform,'OutputView',outputView);

if nonrigid
    [D,~] = imregdemons(rgb2gray(recovered),ref,100,'AccumulatedFieldSmoothing',3.0,'PyramidLevels',7);
    recovered = imwarp(recovered,D);
end

if disp
    imshowpair(recovered,ref)
end
end