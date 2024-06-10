import numpy as np
import cv2

def shift_array(padded_array, window_size):
    wy, wx = window_size if isinstance(window_size, (list, tuple)) else (window_size, window_size)
    assert wy % 2 == 1 and wx % 2 == 1, 'only odd window size is valid'

    height = padded_array.shape[0] - wy + 1
    width = padded_array.shape[1] - wx + 1

    for y0 in range(wy):
        for x0 in range(wx):
            yield padded_array[y0:y0 + height, x0:x0 + width]

def reconstruct_bayer(sub_arrays):
    rggb_indices = ((0, 0), (1, 0), (0, 1), (1, 1))

    height, width = sub_arrays[0].shape
    bayer_array = np.empty(shape=(2 * height, 2 * width), dtype=sub_arrays[0].dtype)

    for idx, sub_array in zip(rggb_indices, sub_arrays):
        x0, y0 = idx
        bayer_array[y0::2, x0::2] = sub_array

    return bayer_array

if __name__ == '__main__':
    raw_img = np.fromfile("../images/HisiRAW_4208x3120_8bits_RGGB.raw", dtype="uint8")
    raw_img = raw_img.reshape(3120, 4208)

    height,width = raw_img.shape
    expand_num = 2 #上下左右各自扩2

    expand_img = np.zeros((height+2*expand_num,width+2*expand_num),dtype=raw_img.dtype)

    expand_img[expand_num:expand_num + height, expand_num: expand_num + width] = raw_img  # 原图部分
    expand_img[0:expand_num, expand_num:expand_num + width] = raw_img[0:expand_num, :]  # 填充顶部
    expand_img[-expand_num:, expand_num:expand_num + width] = raw_img[-expand_num:, :]  # 填充底部
    expand_img[:, 0:expand_num] = expand_img[:, expand_num:expand_num * 2]  # 填充左侧
    expand_img[:, -expand_num:] = expand_img[:, width:width + expand_num]  # 填充右侧


    #把rggb的每一个通道提取出来
    rggb_index = ((0, 0), (1, 0), (0, 1), (1, 1))
    padded_sub_arrays = []
    for index in rggb_index:
        x0,y0 = index
        padded_sub_arrays.append(expand_img[y0::2,x0::2])

    dpc_sub_arrays = []

    for padded_array in padded_sub_arrays:
        #以此处理 r gr gb b三个通道数据
        shifted_arrays = tuple(shift_array(padded_array, window_size=3))  # generator --> tuple

        mask = (np.abs(shifted_arrays[4] - shifted_arrays[1]) > 30) * \
               (np.abs(shifted_arrays[4] - shifted_arrays[7]) > 30) * \
               (np.abs(shifted_arrays[4] - shifted_arrays[3]) > 30) * \
               (np.abs(shifted_arrays[4] - shifted_arrays[5]) > 30) * \
               (np.abs(shifted_arrays[4] - shifted_arrays[0]) > 30) * \
               (np.abs(shifted_arrays[4] - shifted_arrays[2]) > 30) * \
               (np.abs(shifted_arrays[4] - shifted_arrays[6]) > 30) * \
               (np.abs(shifted_arrays[4] - shifted_arrays[8]) > 30)

        dv = np.abs(2 * shifted_arrays[4] - shifted_arrays[1] - shifted_arrays[7])
        dh = np.abs(2 * shifted_arrays[4] - shifted_arrays[3] - shifted_arrays[5])
        ddl = np.abs(2 * shifted_arrays[4] - shifted_arrays[0] - shifted_arrays[8])
        ddr = np.abs(2 * shifted_arrays[4] - shifted_arrays[6] - shifted_arrays[2])
        indices = np.argmin(np.dstack([dv, dh, ddl, ddr]), axis=2)[..., None]

        neighbor_up_down = (shifted_arrays[1] + shifted_arrays[7]) / 2
        neighbor_left_right = (shifted_arrays[3] + shifted_arrays[5]) / 2
        neighbor_diag_topleft_bottomright = (shifted_arrays[0] + shifted_arrays[8]) / 2
        neighbor_diag_topright_bottomleft = (shifted_arrays[6] + shifted_arrays[2]) / 2

        # 将这些方向的邻居平均值放入一个新的维度
        neighbor_stack = np.stack([neighbor_up_down, neighbor_left_right, neighbor_diag_topleft_bottomright,
                                   neighbor_diag_topright_bottomleft], axis=-1)

        dpc_array = np.take_along_axis(neighbor_stack, indices, axis=2).squeeze(2)
        dpc_sub_arrays.append(
            mask * dpc_array + ~mask * shifted_arrays[4]
        )

        dpc_bayer = reconstruct_bayer(dpc_sub_arrays)

        dpc_bayer = dpc_bayer.astype(np.uint8)

        cv2.imwrite("dpc.png",dpc_bayer)
