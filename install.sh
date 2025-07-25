#!/bin/sh
skip=44

tab='	'
nl='
'
IFS=" $tab$nl"

umask=`umask`
umask 77

gztmpdir=
trap 'res=$?
  test -n "$gztmpdir" && rm -fr "$gztmpdir"
  (exit $res); exit $res
' 0 1 2 3 5 10 13 15

if type mktemp >/dev/null 2>&1; then
  gztmpdir=`mktemp -dt`
else
  gztmpdir=/tmp/gztmp$$; mkdir $gztmpdir
fi || { (exit 127); exit 127; }

gztmp=$gztmpdir/$0
case $0 in
-* | */*'
') mkdir -p "$gztmp" && rm -r "$gztmp";;
*/*) gztmp=$gztmpdir/`basename "$0"`;;
esac || { (exit 127); exit 127; }

case `echo X | tail -n +1 2>/dev/null` in
X) tail_n=-n;;
*) tail_n=;;
esac
if tail $tail_n +$skip <"$0" | gzip -cd > "$gztmp"; then
  umask $umask
  chmod 700 "$gztmp"
  (sleep 5; rm -fr "$gztmpdir") 2>/dev/null &
  "$gztmp" ${1+"$@"}; res=$?
else
  echo >&2 "Cannot decompress $0"
  (exit 127); res=127
fi; exit $res
��"Uhinstall.sh �kSY�{~ŵM	�l�$a��eV������"�
IC�L��ta0S�y鈨�2�����w����;�'�{o�_��nm��UI�{����<���I�7,����[Ȥ#\;�IRJlg�~���s�4�b��(��q7l<�����%�O���ms�q���k�Љ�.�킇K��I
��|�y��p:CB2>�p\��*�\n���>O�q����y����s_wV����o���]��
��� v����
����܂���B$G!.�C!���1�$8Q�c����HL@.1�a+�5�A�a+�>*�8�78(Y��=U�A�l`?*'2�E�A~~CY�(��)��ܞ*���7��(/J�SJ���Ci����̿�g���s��Q��'+5�KȃO�Ĉ0�����h�O�ݍ��\^�O����F��5Fݎ����ԅ��ĸ���D"��j��(��"�b�'�c(*8�����" � l��:���d&?�������b�����E�@(���|�X4�IXA�d�	�h�x�5*$9|�T'���E�L��xn&Np�|8��'r%Z4��	��8x��hL�c0�D�ߦKr�����8S��	$�B�̰���ƴ<{_�[W��F�'o�'��H�ˊΉ��>ͅ%.��T(ʧ����� r�TX�����m]Q�][fP�Ş�+@�R�]ڪٽ�����rវ{$om*���%0|y�A)�lwcY�pq����<Zy:��6)�^����W��yq�*����K�o�S�����y����<1N��;�1��y� ?��*(�^+�yy�n�Մrwz����y�=�bT�f�d�N���sR(#ri8�T,F���%=��ŵ5Dem���Aͥw�4�(��1-�h��,t ���j��N��}�k�ǟ��I�֪<;���UEKC�,.��UkeVIY)n��?�19���fm[�jР+Pn�	,��� �	�$����5�������%��z�&�a�%x�'kήZ��Os)��;l�� ��",��9'=�x��ݭ�σ0�_�h&Á����dI�V�䎰�ɪN�����.�B� �˘jр�s���4�%�x���%-m��/&)���&�Y�ک��HIz���/�s ]�e����q�F;J(M��2�W<E�����P�'�3��\����Si>)!�'ۤ��hE���l��5ڑ�Ȥ�Ʀ��Y��-J'��҇0ۀ�҄�J2"�ZyW� ��E+l�К������`h{K�nL�
�}�x#����)e"�����?WhH���R,�)n-�v�(3+��5g�pU�d`z�smQEQ�<{Ȧ^QI�sK�����H��ʮ�+Ϯ��Q�p1��j��T��8T�{F�*ŝ�,�1�w}��5��
��"�:�}��.6̀�e*��K���һu��(j��nfH��2�94�WOa�jiK�V�̒�������՛����H{�56yj���Y'p�v��df������T<#��2}˧�g
�$����tjZd3�$Q�K��b���<����́%�l����,���Z\_V���9�I@�E��&�@hY �aZ��>T3�I��^y�+�\���6�Q]�Tg�UY��az��)e�nI�y�x*�L�wi]�LDĹ�%�ĵģ��NT]|��F�1jɉ���6����k��:^�;'��VquRޜu@�JK�F3�Z=B}>�샇�����A$T?�Uٜ*�<�soi��R��%ላ�?A )�K��Y�������݈��k�7������!�S�_]�٠QDIH!��6�r=�i�հ��K]�Ǜ�ڈ�=V�ד��F��؈0{�=Š���yi�t�g���������)K@�L4�a�j4�x����E���h֔��5���S|ߐ[H��L�XL�	n^`+�B׿]m� ��{MT��Lo������.t��u���!�)}6N�ze�%�g&
j�t�m�Tb�,
|�`��IӎU�<�L(��^�U4����t5���ٿt*s�j�T�1�tO����
����͸&��p4���F�Z��X>	ŝE�9ɛm�����(yң5����O�e��o<����͞��u��7؊?|���i!�Ga��?r��Tei�����K����AK�3�уLL�̩����8�(q$�n�NV��'�D.J������ϻ���\ǥ��K@��<n��h��_�+OL+3�����U�DNY\k���"������ΐG�[�ꢸ�&t��k�]�b&ҧ/t~u�3�eGwg���ҙ �f�4K����Z׳����yf1�:Y��:�D�B�p-�����E�E��ɸ�֠��k�$ݵ��Bo8^g�a%Y/Y��Y��۸ꓪ����*"��e�4WP�--ɷ�K��B��pz�0�[�)έ��Δ�T�`m�Ҁ��+��x;? q8+�����C4��Sjdv����z��q$����eRi�>�B��u�7�鈁L� �MK���m�֪��)~��m�������+��eY(�+�͖^�䇫Ԯ�[+�Ė�~��������@zÜ�}n����?���F7Ԡ�G���s-��/��C�y�Ъ�ƅ�4�����V��")
�e���G���;W��Q����@ǏW������i(CN��T�k'��w����jK�B7����ٮ{e��#Lz��bV�Q�n��K�O�+}��]ԍ�[t���xN��ڐ�O�s�pT(`�X��t��5F�S��zf��Y2��j�݉�;&%�L�\�Y�rߣ���=T�Q����Q�l	%���`������j�(u$�� -o���K<���_���)�#9	Ҏ���P��o
���#  