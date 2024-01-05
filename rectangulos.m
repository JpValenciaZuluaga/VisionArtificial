% Crear un objeto de cámara
cam = webcam;

% Crear una figura para mostrar la información
fig = figure;

while ishandle(fig)
    % Capturar un fotograma desde la cámara
    frame = snapshot(cam);

    % Convertir la imagen a escala de grises
    frame_hsv = rgb2hsv(frame);
    
    % Definir umbrales para el color amarillo en HSV
    umbral_amarillo_min = [0.1, 0.5, 0.4];
    umbral_amarillo_max = [0.2, 1, 1];

    % Crear una máscara para el color amarillo
    mask_amarillo = (frame_hsv(:,:,1) >= umbral_amarillo_min(1)) & (frame_hsv(:,:,1) <= umbral_amarillo_max(1)) & ...
                    (frame_hsv(:,:,2) >= umbral_amarillo_min(2)) & (frame_hsv(:,:,2) <= umbral_amarillo_max(2)) & ...
                    (frame_hsv(:,:,3) >= umbral_amarillo_min(3)) & (frame_hsv(:,:,3) <= umbral_amarillo_max(3));
    
    % Aplicar la máscara al fotograma original
    frame_amarillo = frame;
    frame_amarillo(repmat(~mask_amarillo, [1, 1, 3])) = 0;

    frame_amarillo1 = frame_amarillo(:,:,3);
    frame_amarillo1 = mat2gray(frame_amarillo1);

    % Binarizar la imagen y aplicar operaciones morfológicas
    frame_Bw = imbinarize(frame_amarillo1);
    I = bwareaopen(frame_Bw, 130);

    se = strel('disk', 15, 8);
    I = imclose(I, se);

    [B, L] = bwboundaries(I, 'nohole');
    labeledImage = logical(L);
    
    % Etiquetar regiones conectadas
    stats = regionprops(labeledImage, 'BoundingBox');

    % Mostrar la imagen original
    imshow(frame);
    hold on;

    % Iterar sobre las regiones y dibujar aquellas que se consideren rectangulares
    for k = 1:length(stats)
        boundingBox = stats(k).BoundingBox;

        % Calcular el aspect ratio de la región
        aspectRatio = boundingBox(3) / boundingBox(4);

        % Define un umbral para considerar rectángulo (ajusta según sea necesario)
        aspectRatioThreshold = 2;

        % Dibujar la región si se considera rectangular
        if  boundingBox(3)>(1.5*boundingBox(4))%(0. < abs(1 - aspectRatio)) < aspectRatioThreshold
            rectangle('Position', boundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
        end
    end

    hold off;

    % Esperar un breve período de tiempo
    pause(0.1);
end

% Limpiar después de la ejecución
clear cam;
