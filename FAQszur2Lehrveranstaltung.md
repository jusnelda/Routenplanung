# FAQs zur 2. Lehrveranstaltung
## WorldFile

1. Was ist ein (ESRI) World File?  
Eine kleine Textdatei, die Georeferenzdaten eines Bildes enthält. Dieser Filialdateityp wurde vom Unternehmen ESRI als Ergänzung für einfache Bildformate eingeführt. Die Dateinamenserweiterung leitet sich vom Bildtyp ab und lautet beispielsweise .jgw, .j2w, .pgw, .gfw oder .tfw für JPEG-, JPEG 2000-, PNG-, GIF- oder TIFF-Bilddaten. Das Bezugssystem fehlt in der Datei. 
Ein World-File enthält 6 Zeilen mit den 6 Parametern der Affintransformation:

    a11 = x-Komponente der Pixelbreite  
    a21 = y-Komponente der Pixelbreite  
    a12 = x-Komponente der Pixelhöhe  
    a22 = y-Komponente der Pixelhöhe (meist negativ)  
    b1 = x-Koordinate des Zentrums des obersten linken Bildpunkts  
    b2 = y-Koordinate des Zentrums des obersten linken Bildpunkts  
    
2. Welche Abbildung ist in einem (ESRI) world File enthalten, um Pixelkoordinaten auf 'Geokoordinaten' zu transformieren?  
Siehe oben
3. In einem Matlab ähnlichem Pseudocode: Wie lautet eine Methode, um diese Transformationsparameter zu berechnen? Stellen Sie hierzu das Gleichungssystem auf und geben Sie an, wie es gelöst werden kann!
```matlab
function [worldfile, roads_geo_out] = calcWorldFile()
% roads_geo_out wird ein shapefile
% Shapefile einlesen
roads = shaperead('boston_roads.shp');

% leere Datenstruktur anlegen
roads_geo_out = roads;

% NAD 83 Proj. - Info aus Geotiff laden
info = geotiffinfo('boston.tif');

for i = 1 : length(roads)
    N = 1; 
    for k = 1 : length(roads(i).X)
        x(N) = roads(i).X(k) * unitsratio('sf', 'm');
        y(N) = roads(i).Y(k) * unitsratio('sf', 'm');
        [roads_geo_out(i).Y(k), roads_geo_out(i).X(k)] = projinv(info, x(N), y(N));
        N = N + 1;
        
    end
end

% Esri World File erstellen
% Pixelkoordinaten aus Screenshot der Karte (Map.png)
M = [554, 620, 1; 196, 511, 1;885 ,635, 1;740, 274, 1];
% Geokoordinaten aus Google Maps herausgeholt
blon = [-71.070726;-71.092461;-71.050471;-71.059216];
blat = [42.351995;42.356956;42.351568;42.367701];

% Lineares Gleichungssystem von Matlab loesen lassen
alon = M\blon;
alat = M\blat;
worldfile(1,1) = alon(1,1);
worldfile(2,1) = alat(1,1);
worldfile(3,1) = alon(2,1);
worldfile(4,1) = alat(2,1);
worldfile(5,1) = alon(3,1);
worldfile(6,1) = alat(3,1);

fileID = fopen('worldfile.pgw','w');
fprintf(fileID, '%2.12f\n',worldfile);

shapewrite(roads_geo_out, 'roads_geo_out.shp')


%save('worldfile','worldfile')
end


```