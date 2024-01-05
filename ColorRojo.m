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
    umbral_rojo_min = [0, 0.5, 0.2];
    umbral_rojo_max = [0.05, 1, 1];

    % Crear una máscara para el color amarillo
    mask_rojo = (frame_hsv(:,:,1) >= umbral_rojo_min(1)) & (frame_hsv(:,:,1) <= umbral_rojo_max(1)) & ...
                    (frame_hsv(:,:,2) >= umbral_rojo_min(2)) & (frame_hsv(:,:,2) <= umbral_rojo_max(2)) & ...
                    (frame_hsv(:,:,3) >= umbral_rojo_min(3)) & (frame_hsv(:,:,3) <= umbral_rojo_max(3));

    % Aplicar la máscara al fotograma original
    frame_rojo = frame;
    frame_rojo(repmat(~mask_rojo, [1, 1, 3])) = 0;

    frame_rojo1=frame_rojo(:,:,3);
    frame_rojo1=mat2gray(frame_rojo1);

     % Aplicar un filtro de mediana para eliminar ruido en frame_amarillo
    frame_rojo_suavizado = wiener2(mask_rojo,[3 3]);
      % Calcular gradientes con el operador de Sobel
    gradiente_x = edge(frame_rojo_suavizado, 'Sobel', 'horizontal');
    gradiente_y = edge(frame_rojo_suavizado, 'Sobel', 'vertical');

    % Calcular la magnitud del gradiente
    magnitud_gradiente = sqrt(gradiente_x.^2 + gradiente_y.^2);

    % Aplicar umbral para obtener la máscara binaria
    umbral = 0.9; % Ajusta según sea necesario
    mascara_segmentada = magnitud_gradiente > umbral;

    % Aplicar la máscara a la imagen original
    frame_segmentado = frame;
    frame_segmentado(repmat(~mascara_segmentada, [1, 1, 3])) = 10;
    
    
    %Amplicacion Operador Canny
    bordes_canny = edge(mascara_segmentada, 'Canny');
    % Aplicar la máscara binaria resultante del operador Canny a la imagen original
    frame_amarillo_segmentado = frame_rojo;
    frame_amarillo_segmentado(repmat(~bordes_canny, [1, 1, 3])) = 0;

    frame_Bw= mat2gray(frame_rojo(:,:,2));
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
    imshowpair(frame_mascara,frame_rojo,'montage');
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
