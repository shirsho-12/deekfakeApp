import argparse
from flask import Flask, jsonify, request, url_for, redirect, send_from_directory
from werkzeug.utils import secure_filename
from io import BytesIO
# import marshal
from pathlib import Path
import numpy as np
import requests
import random
import json
import urllib
# from PIL import Image
import os
from core.checkpoint import CheckpointIO
from core.data_loader import get_test_loader
from core.model import build_model
from core.solver import Solver
from core.wing import FaceAligner
from munch import Munch
from os.path import join as ospj
from pathlib import Path
import shutil

# def img_to_array(img):
#     byte_arr = BytesIO()
#     img.save(byte_arr, format=img.format)
#     byte_arr = byte_arr.getvalue()
#     return byte_arr


app_cache = {"loaders": None, "solver": None, "args": None}


def get_parser():
    parser = argparse.ArgumentParser()
    # model arguments
    parser.add_argument('--img_size', type=int, default=256,
                        help='Image resolution')
    parser.add_argument('--num_domains', type=int, default=2,
                        help='Number of domains')
    parser.add_argument('--latent_dim', type=int, default=16,
                        help='Latent vector dimension')
    parser.add_argument('--hidden_dim', type=int, default=512,
                        help='Hidden dimension of mapping network')
    parser.add_argument('--style_dim', type=int, default=64,
                        help='Style code dimension')

    # weight for objective functions
    parser.add_argument('--lambda_reg', type=float, default=1,
                        help='Weight for R1 regularization')
    parser.add_argument('--lambda_cyc', type=float, default=1,
                        help='Weight for cyclic consistency loss')
    parser.add_argument('--lambda_sty', type=float, default=1,
                        help='Weight for style reconstruction loss')
    parser.add_argument('--lambda_ds', type=float, default=1,
                        help='Weight for diversity sensitive loss')
    parser.add_argument('--ds_iter', type=int, default=100000,
                        help='Number of iterations to optimize diversity sensitive loss')
    parser.add_argument('--w_hpf', type=float, default=1,
                        help='weight for high-pass filtering')

    # training arguments
    parser.add_argument('--randcrop_prob', type=float, default=0.5,
                        help='Probabilty of using random-resized cropping')
    parser.add_argument('--total_iters', type=int, default=100000,
                        help='Number of total iterations')
    parser.add_argument('--resume_iter', type=int, default=0,
                        help='Iterations to resume training/testing')
    parser.add_argument('--batch_size', type=int, default=8,
                        help='Batch size for training')
    parser.add_argument('--val_batch_size', type=int, default=32,
                        help='Batch size for validation')
    parser.add_argument('--lr', type=float, default=1e-4,
                        help='Learning rate for D, E and G')
    parser.add_argument('--f_lr', type=float, default=1e-6,
                        help='Learning rate for F')
    parser.add_argument('--beta1', type=float, default=0.0,
                        help='Decay rate for 1st moment of Adam')
    parser.add_argument('--beta2', type=float, default=0.99,
                        help='Decay rate for 2nd moment of Adam')
    parser.add_argument('--weight_decay', type=float, default=1e-4,
                        help='Weight decay for optimizer')
    parser.add_argument('--num_outs_per_domain', type=int, default=10,
                        help='Number of generated images per domain during sampling')

    # misc
    parser.add_argument('--mode', type=str, required=True,
                        choices=['train', 'sample', 'eval', 'align'],
                        help='This argument is used in solver')
    parser.add_argument('--num_workers', type=int, default=4,
                        help='Number of workers used in DataLoader')
    parser.add_argument('--seed', type=int, default=777,
                        help='Seed for random number generator')
    parser.add_argument('--filename', type=str, default='sample')

    # directory for training
    parser.add_argument('--train_img_dir', type=str, default='data/celeba_hq/train',
                        help='Directory containing training images')
    parser.add_argument('--val_img_dir', type=str, default='data/celeba_hq/val',
                        help='Directory containing validation images')
    parser.add_argument('--sample_dir', type=str, default='expr/samples',
                        help='Directory for saving generated images')
    parser.add_argument('--checkpoint_dir', type=str, default='expr/checkpoints',
                        help='Directory for saving network checkpoints')

    # directory for calculating metrics
    parser.add_argument('--eval_dir', type=str, default='expr/eval',
                        help='Directory for saving metrics, i.e., FID and LPIPS')

    # directory for testing
    parser.add_argument('--result_dir', type=str, default='expr/results',
                        help='Directory for saving generated images and videos')
    parser.add_argument('--src_dir', type=str, default='assets/representative/celeba_hq/src',
                        help='Directory containing input source images')
    parser.add_argument('--ref_dir', type=str, default='assets/representative/celeba_hq/ref',
                        help='Directory containing input reference images')
    parser.add_argument('--inp_dir', type=str, default='assets/representative/custom/female',
                        help='input directory when aligning faces')
    parser.add_argument('--out_dir', type=str, default='assets/representative/celeba_hq/src/female',
                        help='output directory when aligning faces')

    # face alignment
    parser.add_argument('--wing_path', type=str,
                        default='expr/checkpoints/wing.ckpt')
    parser.add_argument('--lm_path', type=str,
                        default='expr/checkpoints/celeba_lm_mean.npz')

    # step size
    parser.add_argument('--print_every', type=int, default=10)
    parser.add_argument('--sample_every', type=int, default=5000)
    parser.add_argument('--save_every', type=int, default=10000)
    parser.add_argument('--eval_every', type=int, default=50000)
    return parser


def predict(text):
    """Returns a PIL image of the text, can be converted to BytesIO if needed"""
    """Long texts will take a long time to process"""
    # img = stargan.main(text)
    # print(text)
    # source_path = Path(text["source_image"])
    # print(source_path)
    # source_path = source_path.parts[:-2]
    # source_path = Path(*source_path)
    # print(source_path)
    # reference_path = Path(text["reference_image"])
    # print(reference_path)
    # reference_path = reference_path.absolute().parent.parent
    # print(source_path)
    # print(reference_path)
    text["src_dir"] = '../../assets/src'
    text["ref_dir"] = '../../assets/ref'
    text['w_hpf'] = 1
    text['resume_iter'] = 100000
    text['checkpoint_dir'] = "expr/checkpoints/celeba_hq"
    text['result_dir'] = "../../assets"
    text['val_batch_size'] = 1

    text.pop("source_image")
    text.pop("reference_image")
    text.pop("batch_size")
    text.pop("total_iters")
    text.pop("latent_dims")
    text.pop("style_dims")
    text.pop("hidden_dims")
    text.pop("learning_rate")
    args_list = []
    for k, v in text.items():
        # if not k.startswith("--"):
        # text[f"--{k}"] = v
        # text.pop(k)
        args_list.extend([f"--{k}", str(v)])
        print(k, v)
    parser = get_parser()
    args = parser.parse_args(args_list)
    # args = parser.parse_args(["--mode", "sample", "--num_domains", "1", "--resume_iter", "100000", "--w_hpf", "1",
    #                           "--checkpoint_dir", "expr/checkpoints/celeba_hq",
    #                           "--result_dir", "../../assets",
    #                           "--src_dir", "assets/representative/celeba_hq/src",
    #                           "--ref_dir", "assets/representative/celeba_hq/ref",
    #                           "--val_batch_size", "4"])
    app_cache['args'] = args
    print(len(subdirs(args.src_dir)))
    print(text)
    if app_cache['loaders'] is None:
        app_cache['loaders'] = Munch(src=get_test_loader(root=args.src_dir,
                                                         img_size=args.img_size,
                                                         batch_size=args.val_batch_size,
                                                         shuffle=False,
                                                         num_workers=args.num_workers),
                                     ref=get_test_loader(root=args.ref_dir,
                                                         img_size=args.img_size,
                                                         batch_size=args.val_batch_size,
                                                         shuffle=False,
                                                         num_workers=args.num_workers))
    if app_cache['solver'] is None:
        app_cache['solver'] = Solver(args=args, ckptios=None)
        app_cache['solver']._load_checkpoint(args.resume_iter)
    solver = app_cache['solver']
    solver.sample(loaders=app_cache['loaders'], file_name="sample")
    # stargan.main(args=parser.parse_args(["--mode", "sample", "--num_domains", "2", "--resume_iter", "100000", "--w_hpf", "1",
    #                                      "--checkpoint_dir", "expr/checkpoints/celeba_hq",
    #                                      "--result_dir", "expr/results/celeba_hq",
    #                                      "--src_dir", "assets/representative/celeba_hq/src",
    #                                      "--ref_dir", "assets/representative/celeba_hq/ref",
    #                                     #  "--output_dir", "../../assets",
    #                                      "--val_batch_size", "4"]))
    # filename = f"{random.randint(1, 100000000000)}.jpg"
    # img.save(f"./imgs/{filename}")
    # return {"data": [{"url": f"{request.url.replace('/main', '/imgs')}/{filename}"}]}
    return {"status": "ok", "filename": "sample.jpg"}


app = Flask(__name__)


@app.route('/main', methods=['POST'])
def main_screen():
    # print(json.loads(request.get_data()))
    if request.method == 'POST':  # or request.method == 'GET':
        # text = json.loads(request.get_data())["text"]
        text = json.loads(request.get_data())

        return predict(text)


@app.route('/crop', methods=['POST'])
def crop():
    if request.method == 'POST':
        text = json.loads(request.get_data())
        print(text)
        source_path = Path(text.pop("source_image"))
        output_path = Path(str(Path.cwd().parent.parent) +
                           "/assets/src/img/temp")
        output_path.mkdir(parents=True, exist_ok=True)
        shutil.copy(source_path, output_path)

        text.pop("reference_image")
        if text["isSource"]:
            text["src_dir"] = '../../assets/src/img/temp'
            text["result_dir"] = '../../assets/src/img'
        else:
            text["src_dir"] = '../../assets/ref/img'
            text["result_dir"] = '../../assets/ref/img'
        text.pop("isSource")
        print(text)
        arg_list = []
        for k, v in text.items():
            arg_list.extend([f"--{k}", str(v)])
        parser = get_parser()
        args = parser.parse_args(arg_list)
        input_dir = args.src_dir
        output_dir = args.result_dir
        app_cache['crop_args'] = args
        face_aligner = FaceAligner(args.wing_path, args.lm_path, 128)
        from torchvision import transforms
        from PIL import Image

        transform = transforms.Compose([
            transforms.Resize((args.img_size, args.img_size)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.5, 0.5, 0.5],
                                 std=[0.5, 0.5, 0.5]),
        ])

        fnames = os.listdir(input_dir)
        print(fnames)
        os.makedirs(output_dir, exist_ok=True)
        fnames.sort()
        for fname in fnames:
            image = Image.open(os.path.join(input_dir, fname)).convert('RGB')
            print("Image opened, image size: ", image.size)
            x = transform(image).unsqueeze(0)
            print("Image transformed")
            x_aligned = face_aligner.align(x)
            print("Image aligned")
            save_image(x_aligned, 1, filename=os.path.join(
                output_dir, "n_"+fname))
        print('Saved the aligned image to %s...' % fname)
        shutil.copy(source_path, output_path)
        # align_faces(args, input_dir, output_dir)
        return {"status": "ok", "filename": "n_"+fnames[0]}


def subdirs(dname):
    return [d for d in os.listdir(dname)
            if os.path.isdir(os.path.join(dname, d))]


def denormalize(x):
    out = (x + 1) / 2
    return out.clamp_(0, 1)


def save_image(x, ncol, filename):
    from torchvision.utils import save_image
    x = denormalize(x)
    save_image(x.cpu(), filename, nrow=ncol, padding=0)


# @app.before_first_request
# def setup():
#     parser = get_parser()
#     args = parser.parse_args(["--mode", "sample", "--num_domains", "1", "--resume_iter", "100000", "--w_hpf", "1",
#                               "--checkpoint_dir", "expr/checkpoints/celeba_hq",
#                              "--result_dir", "expr/results/celeba_hq",
#                               "--src_dir", "assets/representative/celeba_hq/src",
#                               "--ref_dir", "assets/representative/celeba_hq/ref",
#                               #  "--output_dir", "../../assets",
#                               "--val_batch_size", "1"])
#     assert len(subdirs(args.src_dir)) == args.num_domains
#     assert len(subdirs(args.ref_dir)) == args.num_domains
    # app_cache["loaders"] = Munch(src=get_test_loader(root=args.src_dir,
    #                                                  img_size=args.img_size,
    #                                                  batch_size=args.val_batch_size,
    #                                                  shuffle=False,
    #                                                  num_workers=args.num_workers),
    #                              ref=get_test_loader(root=args.ref_dir,
    #                                                  img_size=args.img_size,
    #                                                  batch_size=args.val_batch_size,
    #                                                  shuffle=False,
    #                                                  num_workers=args.num_workers))
    # _, nets_ema = build_model(args)

    # app_cache['ckptios'] = [CheckpointIO(ospj(
    #     args.checkpoint_dir, '{:06d}_nets_ema.ckpt'), data_parallel=True, **nets_ema)]


# @app.route('/imgs/<filename>', methods=['GET'])
# def get_img(filename):
#     return send_from_directory("imgs", filename)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=2500)

app = Flask(__name__)


# @app.route('/')
# def hello_world():
#     json_file = {'query': 'hello_world'}
#     return jsonify(json_file)
