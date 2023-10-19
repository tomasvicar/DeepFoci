function [img] = apply_bb(img,bb)

bb = round(bb);
bb(4:end) = bb(4:end)-1;


% xx=bb(3):bb(3)+bb(6)

img = img(bb(2):bb(2)+bb(5),...
    bb(1):bb(1)+bb(4),...
    bb(3):bb(3)+bb(6),...
    :);
end