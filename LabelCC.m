function [] = LabelCC()
    image_size = 5;
    binary_image = randi(2,image_size,image_size) - ones(image_size);
    disp(binary_image);
    four_connected(binary_image, image_size);

    return
end



function [] = four_connected(binary_image, image_size)
    label = 1;
    label_array = linspace(0,0,image_size/2*image_size);
    label_image = zeros(image_size);
    for i=1:image_size
        for j=1:image_size
            if(binary_image(i,j)==1)
                mark = check_around_label_four(label_image, i, j);
                if(mark == 0)
                    mark = label;
                    label_array(mark) = mark;
                    label = label + 1;
                elseif(mark == -1)
                    max_index = max(label_image(i-1,j),label_image(i,j-1));
                    min_index = min(label_image(i-1,j),label_image(i,j-1));
                    while(min_index ~= label_array(min_index))
                        min_index = label_array(min_index);
                    end
                    mark = min_index;
                    while(max_index > min_index)
                        tmp = label_array(max_index);
                        label_array(max_index) = min_index;
                        max_index = tmp;
                    end
                end
                label_image(i,j) = mark;
            end
        end
    end
    
    shoew_image(label_image, label_array, image_size);
    return
end

function [] = shoew_image(label_image, label_array, image_size)
    new_label_array = linspace(0,0,image_size/2*image_size);
    label = 0;
    for i = 1:image_size/2*image_size
        if(label_array(i) == i)
            label = label + 1;
            new_label_array(i) = label;
        end
    end 

    for i = 1:image_size
        for j = 1:image_size
            if(label_image(i,j) ~= 0)
                label_image(i,j) = new_label_array(label_array(label_image(i,j)));
            end
        end
    end
    
    disp(label_image)

    I = mat2gray(label_image*100,[label*100, 0]);
    figure, imshow(I);
    title("component")
    return
end

function x = check_edge_label(label_image, i, j)
    x = 0;
    if(i==1 && j==1)
        return
    elseif(i==1)
        x = max(label_image(i,j-1), 0);
    elseif(j==1)
        x = max(label_image(i-1,j), 0);
    end
    return 
end

function x =check_around_label_four(label_image, i, j)
    x = 0;
    if(i==1 || j==1)
        x = check_edge_label(label_image, i, j);
        return
    end
    
    top = label_image(i-1, j);
    left = label_image(i, j-1);
    if(top ~= left)
        if(top ~= 0 && left ~= 0)
            x = -1; % conflict
        else
            x = max(top, left);
        end
    else
        x = left;
    end

    return
end
