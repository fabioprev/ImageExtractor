function imageExtractor(dataset)
	if (strcmpi(dataset,'ADNI') == 1)
		fprintf(2,'Searching for all gif images in /home/fabio/IASI-CNR/Datasets/ADNI/**/*.nii...');
		
		files = rdir('/home/fabio/IASI-CNR/Datasets/ADNI/**/*.nii');
		
		fprintf(2,'done!\n');
		
		n = size(files,1);
		
		for i = 1 : n
			if (isempty(strfind(files(i,1).name,'MPR')))
				continue;
			end
			
			filename = strrep(files(i,1).name,'.nii','.gif');
			
			if (exist(filename,'file') == 2)
				fprintf('[%3.f%%] GIF already generated for %s\n', str2double(sprintf('%.f',i / n * 100)), filename);
				
				continue;
			end
			
			nii = load_nii(files(i,1).name);
			
			image = nii.img;
			
			NumSlices = size(image,3);
			
			figure(1);
			
			fprintf(2,'[%3.f%%] Generating %s...',str2double(sprintf('%.f',i / n * 100)), filename);
			
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
	else if (strcmpi(dataset,'OASIS') == 1)
		fprintf(2,'Searching for all img images in /home/fabio/IASI-CNR/Datasets/OASIS/**/mpr-1*.img...');
		
		files = rdir('/home/fabio/IASI-CNR/Datasets/OASIS/**/mpr-1*.img');
		
		fprintf(2,'done!\n');
		
		n = size(files,1);
		
		for i = 1 : n
			indexes = strfind(files(i,1).name,'/');
			
			path = files(i,1).name(1:indexes(length(indexes)));
			
			if (exist(strcat(path,'sections'),'dir') == 7)
				fprintf('[%3.f%%] PNG already generated for %s\n', str2double(sprintf('%.f',i / n * 100)), files(i,1).name);
				
				continue;
			end
			
			mkdir(path,'sections');
			
			sections = analyze75info(files(i,1).name);
			sections = sections.Dimensions(3);
			
			image = analyze75read(files(i,1).name);
			
			fprintf(2,'[%3.f%%] Generating %s...',str2double(sprintf('%.f',i / n * 100)), files(i,1).name(1:indexes(length(indexes))));
			
			for j = 1 : sections
				sectionName = strcat(path,'sections/','section_',sprintf('%03d',j - 1),'.png');
				
				section = flipdim(image(:,:,j),1);
				
				section = section / max(section(:));
				
				imwrite(section,sectionName,'BitDepth',16);
			end
			
			fprintf(2,'done.\n');
		end
	end
end
