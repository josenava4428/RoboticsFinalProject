clear all
close all 
clc

newobjs = instrfind;
fclose(newobjs);

a = arduino();
pause on;
%configure pins here
configurePin(a,'D22','DigitalOutput');
configurePin(a,'D23','DigitalOutput');
configurePin(a,'D26','DigitalOutput');
configurePin(a,'D27','DigitalOutput');
configurePin(a,'D30','DigitalOutput');
configurePin(a,'D31','DigitalOutput');
configurePin(a,'D35','DigitalOutput');
configurePin(a,'D34','DigitalOutput');
configurePin(a,'D38','DigitalOutput');
configurePin(a,'D39','DigitalOutput');
writeDigitalPin(a,'D22',0); % Laser Off
writeDigitalPin(a,'D23',0); % Laser On
 
writeDigitalPin(a,'D26',0); % Wrist Down
writeDigitalPin(a,'D27',0); % Wrist Up

writeDigitalPin(a,'D30',0); % Elbow Up
writeDigitalPin(a,'D31',0); % Elbow Down

writeDigitalPin(a,'D34',0); % Shoulder Up
writeDigitalPin(a,'D35',0); % Shoulder Down

writeDigitalPin(a,'D38',0); % Waist Left
writeDigitalPin(a,'D39',0); % Waist Right

writePWMVoltage(a, 'D2', 3);
writePWMVoltage(a, 'D3', 3);
writePWMVoltage(a, 'D4', 3);
writePWMVoltage(a, 'D5', 3);
writePWMVoltage(a, 'D6', 1.7);
%
hflag = 0;
vflag = 0;
bflag = 0;
objects = imaqfind;
delete(objects);

cam = webcam('USB2.0 PC CAMERA');

s = serial('/dev/cu.Bluetooth-Incoming-Port','BaudRate',115200);
fopen(s);

targets = menu('How many targets would you like to hit?', '1', '2');
if targets == 1
    color = menu('Which color would you like to hit?', 'Red', 'Blue');
    if color == 1
        % do red stuff
        while(1)
           %get snapshot of the current frame
           data = snapshot(cam);
           diff_im = imsubtract(data(:,:,2), rgb2gray(data)); 
           %use a median filter to filter out noise
           diff_im = medfilt2(diff_im, [3,3]);
           %convert resulting grayscale image into a binary image
           diff_im = im2bw(diff_im, 0.18);

           %remove all pixels less than 300px
           diff_im = bwareaopen(diff_im, 300);

           %label all conected components in the image
           bw = bwlabel(diff_im, 8);

           %we get a set of properties for each labeles region
           stats = regionprops(bw, 'BoundingBox', 'Centroid');

           %display the image
           imshow(data);

           hold on
           %this loop bounds red objects in a rectangular box
           for object = 1:length(stats)
               bb = stats(object).BoundingBox;
               bc = stats(object).Centroid;
               disp(double(bc));
               rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2)
               plot(bc(1), bc(2), '-m+')
               cords = text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
               set(cords, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
               fwrite(s, '1');
               hold off
               if bc(1) < 235 %245
                   %move right
                   writeDigitalPin(a,'D38',1);
                   writeDigitalPin(a,'D39',0);
               elseif bc(1) > 405 %395
                   %move left
                   writeDigitalPin(a,'D39',1);
                   writeDigitalPin(a,'D38',0);
               else
                   %stops
                   hflag = 1;
                   writeDigitalPin(a,'D38',0);
                   writeDigitalPin(a,'D39',0);
               end
               if bc(2) < 180 %190
                   %move up
                   writeDigitalPin(a,'D27',1);
                   writeDigitalPin(a,'D26',0);
               elseif bc(2) > 320 %310
                   %move down
                   writeDigitalPin(a,'D26',1);
                   writeDigitalPin(a,'D27',0);
               else
                   %stops
                   vflag = 1;
                   writeDigitalPin(a,'D27',0);
                   writeDigitalPin(a,'D26',0);
               end
               if vflag == 1 && hflag ==1
                   writeDigitalPin(a,'D23',1);
                   writeDigitalPin(a,'D27',0);
                   writeDigitalPin(a,'D26',0);
                   writeDigitalPin(a,'D38',0);
                   writeDigitalPin(a,'D39',0);
                   pause(3);
                   bflag = 1;
                   break;
               end
           end
           if bflag == 1
              break;
           end
        end
    else
        % do blue stuff
        while(1)
           %get snapshot of the current frame
           data = snapshot(cam);
           diff_im = imsubtract(data(:,:,3), rgb2gray(data)); 
           %use a median filter to filter out noise
           diff_im = medfilt2(diff_im, [3,3]);
           %convert resulting grayscale image into a binary image
           diff_im = im2bw(diff_im, 0.18);

           %remove all pixels less than 300px
           diff_im = bwareaopen(diff_im, 300);

           %label all conected components in the image
           bw = bwlabel(diff_im, 8);

           %we get a set of properties for each labeles region
           stats = regionprops(bw, 'BoundingBox', 'Centroid');

           %display the image
           imshow(data);

           hold on
           %this loop bounds red objects in a rectangular box
           for object = 1:length(stats)
               bb = stats(object).BoundingBox;
               bc = stats(object).Centroid;
               disp(double(bc));
               rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2)
               plot(bc(1), bc(2), '-m+')
               cords = text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
               set(cords, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
               fwrite(s, '1');
               hold off
               if bc(1) < 235
                   %move right
                   writeDigitalPin(a,'D38',1);
                   writeDigitalPin(a,'D39',0);
               elseif bc(1) > 405
                   %move left
                   writeDigitalPin(a,'D39',1);
                   writeDigitalPin(a,'D38',0);
               else
                   %stops
                   hflag = 1;
                   writeDigitalPin(a,'D38',0);
                   writeDigitalPin(a,'D39',0);
               end
               if bc(2) < 180
                   %move up
                   writeDigitalPin(a,'D27',1);
                   writeDigitalPin(a,'D26',0);
               elseif bc(2) > 320
                   %move down
                   writeDigitalPin(a,'D26',1);
                   writeDigitalPin(a,'D27',0);
               else
                   %stops
                   vflag = 1;
                   writeDigitalPin(a,'D27',0);
                   writeDigitalPin(a,'D26',0);
               end
               if vflag == 1 && hflag ==1
                   writeDigitalPin(a,'D23',1);
                   writeDigitalPin(a,'D27',0);
                   writeDigitalPin(a,'D26',0);
                   writeDigitalPin(a,'D38',0);
                   writeDigitalPin(a,'D39',0);
                   pause(3);
                   bflag = 1;
                   break;
               end
           end
           if bflag == 1
              break 
           end
        end
    end
elseif targets == 2
    order = menu('Which color would you like to hit first?', 'Red', 'Blue');
    if order == 1
        % red first 
        while(1)
            %get snapshot of the current frame
            data = snapshot(cam);
            diff_im = imsubtract(data(:,:,1), rgb2gray(data));
            %use a median filter to filter out noise
            diff_im = medfilt2(diff_im, [3,3]);
            %convert resulting grayscale image into a binary image
            diff_im = im2bw(diff_im, 0.18);
            
            %remove all pixels less than 300px
            diff_im = bwareaopen(diff_im, 300);
            
            %label all conected components in the image
            bw = bwlabel(diff_im, 8);
            
            %we get a set of properties for each labeles region
            stats = regionprops(bw, 'BoundingBox', 'Centroid');
            
            %display the image
            imshow(data);
            
            hold on
            %this loop bounds red objects in a rectangular box
            for object = 1:length(stats)
                bb = stats(object).BoundingBox;
                bc = stats(object).Centroid;
                disp(double(bc));
                rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2)
                plot(bc(1), bc(2), '-m+')
                cords = text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
                set(cords, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
                fwrite(s, '1');
                hold off
                if bc(1) < 235
                    %move right
                    writeDigitalPin(a,'D38',1);
                    writeDigitalPin(a,'D39',0);
                elseif bc(1) > 405
                    %move left
                    writeDigitalPin(a,'D39',1);
                    writeDigitalPin(a,'D38',0);
                else
                    %stops
                    hflag = 1;
                    writeDigitalPin(a,'D38',0);
                    writeDigitalPin(a,'D39',0);
                end
                if bc(2) < 180
                    %move up
                    writeDigitalPin(a,'D27',1);
                    writeDigitalPin(a,'D26',0);
                elseif bc(2) > 320
                    %move down
                    writeDigitalPin(a,'D26',1);
                    writeDigitalPin(a,'D27',0);
                else
                    %stops
                    vflag = 1;
                    writeDigitalPin(a,'D27',0);
                    writeDigitalPin(a,'D26',0);
                end
                if vflag == 1 && hflag ==1
                    writeDigitalPin(a,'D23',1);
                    writeDigitalPin(a,'D27',0);
                    writeDigitalPin(a,'D26',0);
                    writeDigitalPin(a,'D38',0);
                    writeDigitalPin(a,'D39',0);
                    pause(3);
                    bflag = 1;
                    break;
                end
            end
            if bflag == 1
                break
            end
        end
        hflag = 0;
        vflag = 0;
        bflag = 0;
        writeDigitalPin(a,'D23',0);
        % now blue
        while(1)
            %get snapshot of the current frame
            data = snapshot(cam);
            diff_im = imsubtract(data(:,:,3), rgb2gray(data));
            %use a median filter to filter out noise
            diff_im = medfilt2(diff_im, [3,3]);
            %convert resulting grayscale image into a binary image
            diff_im = im2bw(diff_im, 0.18);
            
            %remove all pixels less than 300px
            diff_im = bwareaopen(diff_im, 300);
            
            %label all conected components in the image
            bw = bwlabel(diff_im, 8);
            
            %we get a set of properties for each labeles region
            stats = regionprops(bw, 'BoundingBox', 'Centroid');
            
            %display the image
            imshow(data);
            
            hold on
            %this loop bounds red objects in a rectangular box
            for object = 1:length(stats)
                bb = stats(object).BoundingBox;
                bc = stats(object).Centroid;
                disp(double(bc));
                rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2)
                plot(bc(1), bc(2), '-m+')
                cords = text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
                set(cords, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
                fwrite(s, '1');
                hold off
                if bc(1) < 235
                    %move right
                    writeDigitalPin(a,'D38',1);
                    writeDigitalPin(a,'D39',0);
                elseif bc(1) > 405
                    %move left
                    writeDigitalPin(a,'D39',1);
                    writeDigitalPin(a,'D38',0);
                else
                    %stops
                    hflag = 1;
                    writeDigitalPin(a,'D38',0);
                    writeDigitalPin(a,'D39',0);
                end
                if bc(2) < 180
                    %move up
                    writeDigitalPin(a,'D27',1);
                    writeDigitalPin(a,'D26',0);
                elseif bc(2) > 320
                    %move down
                    writeDigitalPin(a,'D26',1);
                    writeDigitalPin(a,'D27',0);
                else
                    %stops
                    vflag = 1;
                    writeDigitalPin(a,'D27',0);
                    writeDigitalPin(a,'D26',0);
                end
                if vflag == 1 && hflag ==1
                    writeDigitalPin(a,'D23',1);
                    writeDigitalPin(a,'D27',0);
                    writeDigitalPin(a,'D26',0);
                    writeDigitalPin(a,'D38',0);
                    writeDigitalPin(a,'D39',0);
                    pause(3);
                    bflag = 1;
                    break;
                end
            end
            if bflag == 1
                break
            end
        end
    else
        % blue first
        while(1)
            %get snapshot of the current frame
            data = snapshot(cam);
            diff_im = imsubtract(data(:,:,3), rgb2gray(data));
            %use a median filter to filter out noise
            diff_im = medfilt2(diff_im, [3,3]);
            %convert resulting grayscale image into a binary image
            diff_im = im2bw(diff_im, 0.18);
            
            %remove all pixels less than 300px
            diff_im = bwareaopen(diff_im, 300);
            
            %label all conected components in the image
            bw = bwlabel(diff_im, 8);
            
            %we get a set of properties for each labeles region
            stats = regionprops(bw, 'BoundingBox', 'Centroid');
            
            %display the image
            imshow(data);
            
            hold on
            %this loop bounds red objects in a rectangular box
            for object = 1:length(stats)
                bb = stats(object).BoundingBox;
                bc = stats(object).Centroid;
                disp(double(bc));
                rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2)
                plot(bc(1), bc(2), '-m+')
                cords = text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
                set(cords, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
                fwrite(s, '1');
                hold off
                if bc(1) < 235
                    %move right
                    writeDigitalPin(a,'D38',1);
                    writeDigitalPin(a,'D39',0);
                elseif bc(1) > 405
                    %move left
                    writeDigitalPin(a,'D39',1);
                    writeDigitalPin(a,'D38',0);
                else
                    %stops
                    hflag = 1;
                    writeDigitalPin(a,'D38',0);
                    writeDigitalPin(a,'D39',0);
                end
                if bc(2) < 180
                    %move up
                    writeDigitalPin(a,'D27',1);
                    writeDigitalPin(a,'D26',0);
                elseif bc(2) > 320
                    %move down
                    writeDigitalPin(a,'D26',1);
                    writeDigitalPin(a,'D27',0);
                else
                    %stops
                    vflag = 1;
                    writeDigitalPin(a,'D27',0);
                    writeDigitalPin(a,'D26',0);
                end
                if vflag == 1 && hflag ==1
                    writeDigitalPin(a,'D23',1);
                    writeDigitalPin(a,'D27',0);
                    writeDigitalPin(a,'D26',0);
                    writeDigitalPin(a,'D38',0);
                    writeDigitalPin(a,'D39',0);
                    pause(3);
                    bflag = 1;
                    break;
                end
            end
            if bflag == 1
                break
            end
        end
        hflag = 0;
        vflag = 0;
        bflag = 0;
        writeDigitalPin(a,'D23',0);
        %now red
        while(1)
            %get snapshot of the current frame
            data = snapshot(cam);
            diff_im = imsubtract(data(:,:,1), rgb2gray(data));
            %use a median filter to filter out noise
            diff_im = medfilt2(diff_im, [3,3]);
            %convert resulting grayscale image into a binary image
            diff_im = im2bw(diff_im, 0.18);
            
            %remove all pixels less than 300px
            diff_im = bwareaopen(diff_im, 300);
            
            %label all conected components in the image
            bw = bwlabel(diff_im, 8);
            
            %we get a set of properties for each labeles region
            stats = regionprops(bw, 'BoundingBox', 'Centroid');
            
            %display the image
            imshow(data);
            
            hold on
            %this loop bounds red objects in a rectangular box
            for object = 1:length(stats)
                bb = stats(object).BoundingBox;
                bc = stats(object).Centroid;
                disp(double(bc));
                rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2)
                plot(bc(1), bc(2), '-m+')
                cords = text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
                set(cords, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
                fwrite(s, '1');
                hold off
                if bc(1) < 235
                    %move right
                    writeDigitalPin(a,'D38',1);
                    writeDigitalPin(a,'D39',0);
                elseif bc(1) > 405
                    %move left
                    writeDigitalPin(a,'D39',1);
                    writeDigitalPin(a,'D38',0);
                else
                    %stops
                    hflag = 1;
                    writeDigitalPin(a,'D38',0);
                    writeDigitalPin(a,'D39',0);
                end
                if bc(2) < 180
                    %move up
                    writeDigitalPin(a,'D27',1);
                    writeDigitalPin(a,'D26',0);
                elseif bc(2) > 320
                    %move down
                    writeDigitalPin(a,'D26',1);
                    writeDigitalPin(a,'D27',0);
                else
                    %stops
                    vflag = 1;
                    writeDigitalPin(a,'D27',0);
                    writeDigitalPin(a,'D26',0);
                end
                if vflag == 1 && hflag ==1
                    writeDigitalPin(a,'D23',1);
                    writeDigitalPin(a,'D27',0);
                    writeDigitalPin(a,'D26',0);
                    writeDigitalPin(a,'D38',0);
                    writeDigitalPin(a,'D39',0);
                    pause(3);
                    bflag = 1;
                    break;
                end
            end
            if bflag == 1
                break;
            end
        end
    end
end
fclose(s);
delete(s);
pause off;
clear all;
close all;