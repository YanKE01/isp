import cv2
import numpy as np

class BLC:
    def __init__(self, inputs: np.ndarray, bayer_pattern: str, bayer_depth: int, black_level_r: float = 0,
                 black_level_gr: float = 0, black_level_gb: float = 0, black_level_b: float = 0) -> None:
        super().__init__()
        self.inputs = inputs
        self.bayer_patten = bayer_pattern
        self.bayer_depth = bayer_depth
        self.black_level_r = black_level_r
        self.black_level_gb = black_level_gb
        self.black_level_gr = black_level_gr
        self.black_level_b = black_level_b

        # 判断输入是否合规
        assert self.bayer_patten in ["rggb", "bggr", "grbg", "gbgr"]
        assert self.bayer_depth in [8, 10, 16]
        assert self.inputs is not None
        assert len(self.inputs.shape) == 2

    def __bayer_rggb_blc(self) -> np.ndarray:
        blc_output = np.copy(self.inputs).astype(np.float32)
        blc_output[0::2, 0::2] = self.inputs[0::2, 0::2] - self.black_level_r
        blc_output[0::2, 1::2] = self.inputs[0::2, 1::2] - self.black_level_gr
        blc_output[1::2, 0::2] = self.inputs[1::2, 0::2] - self.black_level_gb
        blc_output[1::2, 1::2] = self.inputs[1::2, 1::2] - self.black_level_b

        return blc_output

    def __bayer_bggr_blc(self) -> np.ndarray:
        blc_output = np.copy(self.inputs).astype(np.float32)
        blc_output[0::2, 0::2] = self.inputs[0::2, 0::2] - self.black_level_b
        blc_output[0::2, 1::2] = self.inputs[0::2, 1::2] - self.black_level_gb
        blc_output[1::2, 0::2] = self.inputs[1::2, 0::2] - self.black_level_gr
        blc_output[1::2, 1::2] = self.inputs[1::2, 1::2] - self.black_level_r
        return blc_output

    def __bayer_grbg_blc(self) -> np.ndarray:
        blc_output = np.copy(self.inputs).astype(np.float32)
        blc_output[0::2, 0::2] = self.inputs[0::2, 0::2] - self.black_level_gr
        blc_output[0::2, 1::2] = self.inputs[0::2, 1::2] - self.black_level_r
        blc_output[1::2, 0::2] = self.inputs[1::2, 0::2] - self.black_level_b
        blc_output[1::2, 1::2] = self.inputs[1::2, 1::2] - self.black_level_gb
        return blc_output

    def __bayer_gbrg_blc(self) -> np.ndarray:
        blc_output = np.copy(self.inputs).astype(np.float32)
        blc_output[0::2, 0::2] = self.inputs[0::2, 0::2] - self.black_level_gb
        blc_output[0::2, 1::2] = self.inputs[0::2, 1::2] - self.black_level_b
        blc_output[1::2, 0::2] = self.inputs[1::2, 0::2] - self.black_level_r
        blc_output[1::2, 1::2] = self.inputs[1::2, 1::2] - self.black_level_gr
        return blc_output

    def run(self) -> np.ndarray:
        __dict = {
            "rggb": self.__bayer_rggb_blc,
            "bggr": self.__bayer_bggr_blc,
            "grbg": self.__bayer_grbg_blc,
            "gbrg": self.__bayer_gbrg_blc,
        }
        blc_img = __dict.pop(self.bayer_patten)()

        # 更具depthp做平移处理
        if self.bayer_depth == 8:
            blc_img = np.clip(blc_img, 0, pow(2, 8) - 1).astype(np.uint8)
        elif self.bayer_depth == 10:
            blc_img = np.clip(blc_img, 0, pow(2, 10) - 1).astype(np.uint16)
        elif self.bayer_depth == 16:
            blc_img = np.clip(blc_img, 0, pow(2, 16) - 1).astype(np.uint16)

        return blc_img


if __name__ == '__main__':
    raw_img = np.fromfile("../images/HisiRAW_4208x3120_8bits_RGGB.raw", dtype="uint8")
    raw_img = raw_img.reshape(3120, 4208)
    blc = BLC(inputs=raw_img, bayer_pattern="rggb", bayer_depth=10, black_level_r=64.0, black_level_gb=64.0,
              black_level_gr=64.0, black_level_b=64.0)
    blc_output = blc.run()
    blc_output = cv2.normalize(blc_output, None, 0, 255, cv2.NORM_MINMAX).astype(np.uint8)

    cv2.imshow("blc",blc_output)
    cv2.waitKey(0)