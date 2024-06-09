import cv2
import numpy as np


class DPC:
    def __init__(self, inputs: np.ndarray, bayer_patten: str, bayer_depth: int, threshold: float) -> None:
        super().__init__()
        self.inputs = inputs
        self.bayer_patten = bayer_patten
        self.threshold = threshold
        self.expand = 2
        self.height = inputs.shape[0]
        self.width = inputs.shape[1]
        self.bayer_depth = bayer_depth
        self.img_expand = np.zeros((inputs.shape[0] + 2*self.expand, inputs.shape[1] + 2*self.expand), dtype=inputs.dtype)
        self.around_point = np.zeros((1,8))
        print("height:{},width:{}".format(self.height,self.width))

        # 判断输入是否合规
        assert self.inputs is not None
        assert self.bayer_patten in ["rggb", "bggr", "grbg", "gbgr"]
        assert self.bayer_depth in [8, 10, 16]
        assert len(self.inputs.shape) == 2

    def expand_img(self):
        # 上下扩两边
        self.img_expand[self.expand:self.expand + self.height, self.expand: self.expand + self.width] = self.inputs  # 原图部分
        self.img_expand[0:self.expand, self.expand:self.expand + self.width] = self.inputs[0:self.expand, :]  # 填充顶部
        self.img_expand[-self.expand:,self.expand:self.expand + self.width] = self.inputs[-self.expand:, :]  # 填充底部
        self.img_expand[:, 0:self.expand] = self.img_expand[:, self.expand:self.expand * 2] #填充左侧
        self.img_expand[:,-self.expand:] = self.img_expand[:,self.width:self.width+self.expand] #填充右侧

    def pinto(self, current_point, around_array: np.ndarray, threshold: float) -> np.uint8:
        media_value = np.median(around_array)  # 求取中位数
        diff = around_array - np.ones((1, len(around_array))) * current_point

        if np.sum(diff > 0) == len(around_array) or np.sum(diff < 0) == len(around_array):
            if np.sum(np.abs(diff) > threshold) == len(around_array):
                return media_value  # 用中位值来校准
        return current_point

    def run(self) -> np.ndarray:
        self.expand_img() #扩充图像
        dpc_out = np.zeros(self.inputs.shape,dtype=np.uint8)
        for i in range(self.expand,self.height+self.expand,2):
            for j in range(self.expand,self.expand+self.width,2):
                around_r_pixel = np.array(
                    [self.img_expand[i - 2][j - 2], self.img_expand[i - 2][j], self.img_expand[i - 2][j + 2],
                     self.img_expand[i][j - 2], self.img_expand[i][j + 2], self.img_expand[i + 2][j - 2],
                     self.img_expand[i + 2][j], self.img_expand[i + 2][j + 2]])
                dpc_out[i-self.expand][j-self.expand]=self.pinto(self.img_expand[i][j],around_r_pixel,self.threshold)

                around_gr_pixel = np.array(
                    [self.img_expand[i - 1][j], self.img_expand[i - 2][j + 1], self.img_expand[i - 1][j + 2],
                     self.img_expand[i][j - 1], self.img_expand[i][j + 3], self.img_expand[i + 1][j],
                     self.img_expand[i + 2][j + 1], self.img_expand[i + 1][j + 2]]
                )
                dpc_out[i-self.expand][j-self.expand+1] = self.pinto(self.img_expand[i][j+1],around_gr_pixel,self.threshold)

                around_b_pixel = np.array(
                    [self.img_expand[i - 1][j - 1], self.img_expand[i - 1][j + 1], self.img_expand[i - 1][j + 3],
                     self.img_expand[i + 1][j - 1], self.img_expand[i + 1][j + 3], self.img_expand[i + 3][j - 1],
                     self.img_expand[i + 3][j + 1], self.img_expand[i + 3][j + 3]])
                dpc_out[i - self.expand + 1][j - self.expand+1] = self.pinto(self.img_expand[i+1][j+1],around_b_pixel,self.threshold)

                around_gb_pixel = np.array(
                    [self.img_expand[i][j - 1], self.img_expand[i - 1][j], self.img_expand[i][j + 1],
                     self.img_expand[i + 1][j - 2], self.img_expand[i + 1][j + 2], self.img_expand[i + 2][j - 1],
                     self.img_expand[i + 3][j], self.img_expand[i + 2][j + 1]])
                dpc_out[i-self.expand+1][j-self.expand] = self.pinto(self.img_expand[i+1][j],around_gb_pixel,self.threshold)
        return dpc_out





if __name__ == '__main__':
    """
    only test rggb
    """
    raw_img = np.fromfile("../images/HisiRAW_4208x3120_8bits_RGGB.raw", dtype="uint8")
    raw_img = raw_img.reshape(3120, 4208)
    dpc = DPC(inputs=raw_img, bayer_depth=8, bayer_patten="rggb", threshold=30)

    dpc_out = dpc.run()
    cv2.imwrite("dpc.png",dpc_out)
