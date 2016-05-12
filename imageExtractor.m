function imageExtractor()
	files = rdir('/home/fabio/IASI-CNR/Datasets/ADNI/**/*.nii');
	
	n = size(files,1);
	
	for i = 1 : n
		if (isempty(strfind(files(i,1).name,'MPR')))
			continue;
		end
		
		filename = strrep(files(i,1).name,'.nii','.gif');
		
		if (exist(filename,'file') == 2)
			fprintf('GIF already generated for %s\n', filename);
			
			continue;
		end
		
		nii = load_nii(files(i,1).name);
		
		image = nii.img;
		
		NumSlices = size(image,3);
		
		figure(1);
		
		fprintf(2,'Generating %s...',filename);
		
		for j = 1 : NumSlices
			imshow(image(:,:,j,1),[])
			drawnow
			
			frame = getframe(1);
			
			% Removing grey borders when generating the animated GIF.
			im = imcrop(frame2im(frame),[ 73 24 255 179 ]);
			
			[imind,cm] = rgb2ind(im,256);
			
			if j == 1;
				% Generating GIF at 30 Hz.
				imwrite(imind,cm,filename,'gif','DelayTime',0.033333,'Loopcount',inf);
			else
				% Generating GIF at 30 Hz.
				imwrite(imind,cm,filename,'gif','DelayTime',0.033333,'WriteMode','append');
			end
		end
		
		fprintf(2,'done.\n');
 	end
	
	close all;
end
