function closest_index = closest_segment(index1,index2, end_idx, L)
distance1 = hypot( ( L(index1).x - L(end_idx).x ), ( L(index1).y - L(end_idx).y ) );
distance2 = hypot( ( L(index2).x - L(end_idx).x ), ( L(index2).y - L(end_idx).y ) );

closest_index = index1;
if distance1 > distance2
    closest_index = index2;

end

