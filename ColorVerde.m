% Crear un objeto de la cámara
cam = webcam;

% Configurar la vista previa
%preview(cam);
  

while true
    % Capturar un fotograma desde la cámara
    frame = snapshot(cam);

    % Convertir el fotograma al espacio de color HSV
    frame_hsv = rgb2hsv(frame);

    % Definir umbrales para el color amarillo en HSV
    umbral_verde_min = [0.2, 0.4, 0.1];
    umbral_verde_max = [0.4, 1, 1];

    % Crear una máscara para el color amarillo
    mask_verde = (frame_hsv(:,:,1) >= umbral_verde_min(1)) & (frame_hsv(:,:,1) <= umbral_verde_max(1)) & ...
                    (frame_hsv(:,:,2) >= umbral_verde_min(2)) & (frame_hsv(:,:,2) <= umbral_verde_max(2)) & ...
                    (frame_hsv(:,:,3) >= umbral_verde_min(3)) & (frame_hsv(:,:,3) <= umbral_verde_max(3));

    % Aplicar la máscara al fotograma original
    frame_verde = frame;
    frame_verde(repmat(~mask_verde, [1, 1, 3])) = 0;

    frame_verde1=frame_verde(:,:,3);
    frame_verde1=mat2gray(frame_verde1);

    % Aplicar un filtro de mediana para eliminar ruido en frame_amarillo
    frame_verde_suavizado = wiener2(mask_verde,[3 3]);
      % Calcular gradientes con el operador de Sobel
    gradiente_x = edge(frame_verde_suavizado, 'Sobel', 'horizontal');
    gradiente_y = edge(frame_verde_suavizado, 'Sobel', 'vertical');

    % Calcular la magnitud del gradiente
    magnitud_gradiente = sqrt(gradiente_x.^2 + gradiente_y.^2);

    % Aplicar umbral para obtener la máscara binaria
    umbral = 0.8; % Ajusta según sea necesario
    mascara_segmentada = magnitud_gradiente > umbral;

    % Aplicar la máscara a la imagen original
    frame_segmentado = frame;
    frame_segmentado(repmat(~mascara_segmentada, [1, 1, 3])) = 0;
    
    %Amplicacion Operador Canny
    bordes_canny = edge(mascara_segmentada, 'Canny');

    % Aplicar la máscara binaria resultante del operador Canny a la imagen original
    frame_verde_segmentado = frame_verde;
    frame_verde_segmentado(repmat(~bordes_canny, [1, 1, 3])) = 0;
    frame_Bw= mat2gray(frame_verde(:,:,2));
    Iw=bwareaopen(frame_Bw,130);
    se=strel('disk',15,8);
    Iw=imclose(Iw,se);
    frame_mascara=frame;
    frame_mascara(repmat(~Iw, [1, 1, 3])) = 0;
    %II=histeq(Iw);
    II2=histeq(frameHis(:,:,1));
    hold on
%     subplot(1,3,1)
%     imhist(I)
%     title('Resultado');
%     subplot(1,3,3)
%     imhist(II2)
%     title('Entrada');
    %imhist(II)
    %subplot(1,3,2)
    imshowpair(frame_mascara,frame_verde,'montage');
    % Mostrar el fotograma original y la detección de color amarillo
    %imshowpair(frame_segmentado, frame_rojo, 'montage');
    title('Fotograma Original vs. Detección de Color Rojo');
    %accion = input('salir?');
%     if strcmpi(accion, 'salir')
%         break; % Salir del bucle
%     end
    % Esperar un breve período de tiempo
    pause(0.1);

end
  
% Limpiar después de la ejecución
clear cam;
