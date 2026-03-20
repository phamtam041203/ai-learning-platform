# Ve so do bang Python

Ban co the ve 7 so do truc tiep tu code Python (thay vi Mermaid) bang script:
- `tools/generate_data_diagrams.py`

## Yeu cau
1. Cai Python package:
```bash
pip install graphviz
```
2. Cai Graphviz binary (co lenh `dot` trong PATH).

Windows (goi y):
```powershell
winget install Graphviz.Graphviz
```

## Cach chay
Tu thu muc goc du an:
```bash
python tools/generate_data_diagrams.py
```

## File ket qua
- `docs/diagrams/so_do_luong_du_lieu.png`
- `docs/diagrams/so_do_lien_ket_du_lieu.png`
- `docs/diagrams/so_do_quan_he_du_lieu.png`
- `docs/diagrams/so_do_ho_so_sinh_vien.png`
- `docs/diagrams/so_do_phan_cap_chuc_nang.png`
- `docs/diagrams/so_do_xu_ly_du_lieu_hoc_tap.png`
- `docs/diagrams/so_do_goi_y_noi_dung_hoc_tap.png`

## Ghi chu
- So do duoc sinh tu cau truc du an hien tai (frontend + backend + models).
- Neu bao loi `ExecutableNotFound: dot`, script se tu dong xuat file `.dot` vao `docs/diagrams/`.
- Sau khi cai Graphviz binary, chay lai script de co file PNG.
