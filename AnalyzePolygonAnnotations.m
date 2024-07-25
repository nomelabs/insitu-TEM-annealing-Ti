%% Reads in the data from the text file
clc
clear

% Reads in the file
data = dlmread("Text File Name Here", " ");

% Converts the fractions to pixels (assuming 2048x2048) and rounds to the 
% nearest integer
data = data*2048;
data = round(data,0);

% Draws the polygons onto the picture and finds their area

% Reads in the picture we will be editing
img = imread("Image Name Here");
imshow(img);
hold on;

% Adds the polygons to the image
for a = 1:height(data)
    % Prepares some variables that we need to reset every time the program
    % loops
    x = 0;
    y = 1;
    z = 0;

    % Grabs the x and y coordinates for the lines and puts them into
    % respective arrays
    for b = 1:((width(data)-1)/2)
        x = x + 2;
        y = y + 2;

        % If the x and y is 0, the point is not recorded as this means it
        % is likely an empty portion of the dataset
        if (data(a,x) > 0) && (data(a,y) > 0)
            z = z+1;
            xCoord(z,1) = data(a,x);
            yCoord(z,1) = data(a,y);
        end
    end

    % Plots our polygon using the x and y coordinate arrays
    plot(polyshape(xCoord(:,1),yCoord(:,1)));
    hold on;

    % Finds the max feret diameter which should be in pixels
    % Loop c iterates through which point will be the point we are finding
    % the distance from, or point 1
    for c = 1:height(xCoord)
        % Loop d iterates through which point is our 'destination' from point
        % 1, or point 2
        for d = 1:height(xCoord)
            % Creates the coordinate pair for our function to use
            pair = [xCoord(c,1),yCoord(c,1);xCoord(d,1),yCoord(d,1)];

            % Finds the distance between the points
            pointDistance(d,1) = pdist(pair);
        end

        % Finds and saves the largest distance from point 1 to 2 as this
        % will be a candidate for our feret diameter
        maxPointDistances(c,1) = max(pointDistance);

        % Clears the pointDistance variable
        clear('pointDistance');
    end

    % Finds the max distance of all found diameters, as this will be our
    % maximum feret diameter
    maxFeretDiameter(a,1) = max(maxPointDistances);

    % Finds the area of the polygon we just drew which should be in pixels
    polyArea(a,1) = polyarea(xCoord(:,1),yCoord(:,1));

    % Clears the coordinate arrays so they can be used again
    clear('xCoord');
    clear('yCoord');
    clear('maxPointDistances');
end

% Clears the variables we no longer need so that only relevant variables
% for the calculations below remain
clear('a');
clear('b');
clear('c');
clear('d');
clear('data');
clear('img');
clear('pair');
clear('x');
clear('y');
clear('z');

% Converts area in pixels to real units, enter your distance per pixel here
distance = .2554; % This is in nanometers

% This should give us the real area of each respective polygon in
% the metric of your distance per pixel
polyAreaReal = polyArea(:) * distance * distance;

% Outputs the data wanted
defectPercent = sum(polyAreaReal,'all')/(distance*distance*2048*2048) * 100;
avgDefectSize = sum(polyAreaReal,'all')/height(polyAreaReal);

numPerCm = height(polyAreaReal)/(distance*distance*2048*2048*10^-14);
numPerM3 = height(polyAreaReal)/(distance*2048*distance*2048*170)*10^27;

equivalentDiameter = 2*sqrt(polyAreaReal(:)/pi);
avgEquivalentDiameter = sum(equivalentDiameter) / height(polyAreaReal);

maxFeretDiameter = maxFeretDiameter * distance;
avgFeretDiameter = sum(maxFeretDiameter) / height(polyAreaReal);
FeretStd = std(maxFeretDiameter);