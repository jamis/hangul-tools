# Courtesy of algorithms described at:
# http://gernot-katzers-spice-pages.com/var/korean_hangul_unicode.html

module HangulTools
  def self.romanize(text, system=:revised)
    matrix = matrices[system]
    vowels = VOWELS[system]

    text.scan(/[\uAC00-\uD7a3]+|[^\uAC00-\uD7a3]+/).map.with_index do |string, idx|
      if string =~ /[\uAC00-\uD7a3]/
        romanize_with_system(string, system, idx > 0 ? :voiced : :initial)
      else
        string
      end
    end.join
  end

  LEADS  = [ nil, 'g', 'gg', 'n', 'd', 'dd', 'r', 'm', 'b', 'bb' ,'s', 'ss', nil, 'j', 'jj', 'ch', 'k', 't', 'p', 'h' ]
  TAILS  = [ nil, 'g', 'gg', 'gs', 'n', 'nj', 'nh', 'd', 'l', 'lg', 'lm', 'lb', 'ls', 'lt', 'lp', 'lh', 'm', 'b', 'bs', 's', 'ss', 'ng', 'j', 'ch', 'k', 't', 'p', 'h' ]

  # it is assumed that `text` contains nothing but hangul codepoints
  def self.decompose(text)
    text.codepoints.map do |point|
      tail = (point - 44032) % 28
      vowel = 1 + ((point - 44032 - tail) % 588) / 28
      lead = 1 + (point - 44032) / 588

      [lead, vowel, tail]
    end
  end

  def self.romanize_with_system(text, system, voiced)
    matrix = matrices[system]
    vowels = VOWELS[system]
    blends = BLENDS[system]

    syllables = decompose(text)
    phonemes = []

    syllables.each.with_index do |(lead, vowel, tail), idx|
      prior = (idx > 0) ? TAILS[syllables[idx-1][2].to_i] : voiced
      final = syllables[idx+1] ? false : true

      phonemes << (matrix[prior] || {})[LEADS[lead]]
      phonemes << vowels[vowel]

      if final
        phonemes << (matrix[TAILS[tail]] || {})[:final]
      end
    end

    result = phonemes.compact.join

    blends.each do |pattern, blend|
      result = result.gsub(pattern, blend)
    end

    result
  end

  VOWELS = {
    revised:           [ nil, 'a', 'ae', 'ya', 'yae', 'eo', 'e', 'yeo', 'ye', 'o', 'wa', 'wae', 'oe', 'yo', 'u', 'weo', 'we', 'wi', 'yu', 'eu', 'yi', 'i' ],
    mccune_reischauer: [ nil, 'a', 'ae', 'ya', 'yae', 'ŏ',  'e', 'yŏ',  'ye', 'o', 'wa', 'wae', 'oe', 'yo', 'u', 'wŏ',  'we', 'wi', 'yu', 'ŭ',  'ŭi', 'i' ]
  }

  BLENDS = {
    revised: {},
    mccune_reischauer: { "si" => "shi", "sy" => "shy", "swi" => "shwi" }
  }

  def self.matrices
    @matrices ||= {}.tap do |hash|
      raw = File.read(__FILE__).lines
      split_at = raw.index("__END__\n")

      key = lines = nil
      raw[(split_at+1)..-1].each do |line|
        if line =~ /^(\w+):$/
          hash[key.to_sym] = parse_matrix(lines) if lines
          key = $1
          lines = []
        elsif line !~ /^$/
          lines << line
        end
      end

      hash[key.to_sym] = parse_matrix(lines) if lines
    end
  end

  def self.parse_matrix(lines)
    lead = lines.first.split(/\s+/)[1..-1].map do |v|
      if v == '_'
        nil
      elsif v == 'final'
        :final
      else
        v
      end
    end

    matrix = {}

    lines[1..-1].each do |line|
      tail, *sounds = line.split(/\s+/)

      if tail == 'initial'
        tail = :initial
      elsif tail == 'voiced'
        tail = :voiced
      elsif tail == '_'
        tail = nil
      end

      sounds.map! { |s| s == '_' ? nil : s }

      matrix[tail] = Hash[lead.zip(sounds)]
    end

    matrix
  end
end

__END__
revised:
t\l      g   gg   n   d   dd   r    m    b   bb   s   ss   _   j   jj   ch    k    t    p    h   final
initial  g   kk   n   d   tt   r    m    b   pp   s   ss   _   j   jj   ch    k    t    p    h   _
voiced   g   kk   n   d   tt   r    m    b   pp   s   ss   _   j   jj   ch    k    t    p    h   _
g        kg  kg   ngn kd  ktt  ngn  ngm  kb  kpp  ks  kss  g   kj  kjj  kch   k-k  kt   kp   kh  k
gg       kg  kg   ngn kd  ktt  ngn  ngm  kb  kpp  ks  kss  kk  kj  kjj  kch   k-k  kt   kp   kh  k
gs       kk  kk   ngn kd  ktt  ngn  ngm  kb  kpp  ks  kss  ks  kj  kjj  kch   k-k  kt   kp   kh  k
n        n-g n-kk nn  nd  ntt  ll   nm   nb  npp  ns  nss  n   nj  njj  nch   nk   nt   np   nh  n
nj       ntg ntkk nn  ntd ntt  ll   nm   ntb ntpp nts ntss nj  njj njj  nch   nk   nt   np   nh  nt
nh       nk  nkk  nn  nt  ntt  ll   nm   np  npp  ns  nss  nh  nch njj  nch   nk   nt   np   nh  n
d        tg  tkk  nn  td  tt   nn   nm   tb  tpp  ts  tss  d   tj  tjj  tch   tk   tt   tp   th  t
l        lg  lkk  ll  ld  ltt  ll   lm   lb  lpp  ls  lss  r   lj  ljj  lch   lk   lt   lp   lh  l
lg       lkk lkk  lng lkd lktt lngn lngm lkb lkpp lks lkss lg  lkj lkjj lkch  lk   lkt  lkp  lk  lk
lm       lmg lmkk lmn lmd lmtt lmn  lmm  lmb lmpp lms lmss lm  lmj lmjj lmch  lmk  lmt  lmp  lmh lm
lb       lbg lbkk lmn lbd lbtt lmn  lmm  lpb lpp  lbs lbss lb  lbj lbjj lbch  lbk  lbt  lbp  lbh lp
ls       ltk ltkk ll  ltt ltt  ll   lm   lpp lpp  lss lss  ls  ljj ljj  lch   lk   lt   lp   lt  lt
lt       ltk ltkk ll  ltt ltt  ll   lm   lpp lpp  lss lss  lt  ljj ljj  lch   lk   lt   lp   lt  lt
lp       lpk lpkk lmn lpt lptt lmn  lm   lpp lpp  lps lpss lp  lpj lpjj lpch  lpk  lpt  lp   lpt lp
lh       lk  lkk  ll  lt  ltt  ll   lm   lp  lpp  ls  lss  lh  lch ljj  lch   lk   lt   lp   lh  l
m        mg  mkk  mn  md  mtt  mn   mm   mb  mpp  ms  mss  m   mj  mjj  mch   mk   mt   mp   mh  m
b        pg  pkk  mn  pd  ptt  mn   mm   pb  pp   ps  pss  b   pj  pjj  pch   pk   pt   p-p  ph  p
bs       pg  pkk  mn  pd  ptt  mn   mm   pb  pp   pss pss  ps  pjj pjj  pch   pk   pt   ptp  pt  p
s        tg  tkk  nn  td  tt   nn   nm   tb  tpp  ts  tss  s   tj  tjj  tch   tk   t-t  tp   th  t
ss       tg  tkk  nn  td  tt   nn   nm   tb  tpp  ts  tss  ss  tj  tjj  tch   tk   t-t  tp   th  t
_        g   kk   n   d   tt   r    m    b   pp   s   ss   _   j   jj   ch    k    t    p    h   _
ng       ngg ngkk ngn ngd ngtt ngn  ngm  ngb ngpp ngs ngss ng  ngj ngjj ngch  ngk  ngt  ngp  ngh ng
j        tg  tkk  nn  td  tt   nn   nm   tb  tpp  ts  tss  j   tj  tjj  tch   tk   t-t  tp   th  t
ch       tg  tkk  nn  td  tt   nn   nm   tb  tpp  ts  tss  ch  tj  tjj  tch   tk   t-t  tp   th  t
k        kg  kg   ngn kd  ktt  ngn  ngm  kb  kpp  ks  kss  k   kj  kjj  kch   k-k  kt   kp   kh  k
t        tg  tkk  nn  td  tt   nn   nm   tb  tpp  ts  tss  t   tj  tjj  tch   tk   tt   tp   th  t
p        pg  pkk  mn  pd  ptt  mn   mm   pb  pp   ps  pss  p   pj  pjj  pch   pk   pt   p-p  ph  p
h        k   kk   nn  t   tt   nn   nm   p   pp   hs  hss  h   ch  ch   tch   tk   tt   tp   t   t

mccune_reischauer:
t\l      g   gg   n   d   dd   r    m    b   bb   s   ss   _   j     jj    ch    k    t    p    h    final
initial  k   kk   n   t   tt   r    m    p   pp   s   ss   _   ch    tch   ch'   k'   t'   p'   h    _
voiced   g   kk   n   d   dd   r    m    b   bb   s   ss   _   j     jj    ch'   k'   t'   p'   h    _
g        kk  kk   ngn kt  ktt  ngn  ngm  kp  kpp  ks  kss  g   kj    ktch  kch'  kk'  kt'  kp'  kh   k
gg       kk  kk   ngn kt  ktt  ngn  ngm  kp  kpp  ks  kss  kk  kj    ktch  kch'  kk'  kt'  kp'  kh   kk
gs       kk  kk   ngn kt  ktt  ngn  ngm  kb  kpp  ks  kss  ks  ktch  ktch  kch'  kk'  kt'  kp'  kh   k
n        n'g n'kk nn  nd  ntt  ll   nm   nb  npp  ns  nss  n   nj    ntch  nch'  nk'  nt'  np'  nh   n
nj       nkk nkk  nn  ntt ntt  ll   nm   npp npp  nss nss  nj  ntch  ntch  nch'  nk'  nt'  np'  nch' nt
nh       nk' nkk  nn  nt' ntt  ll   nm   np' npp  nss nss  nh  nch'  ntch  nch'  nk'  nt'  np'  nh   n
d        tk  tkk  nn  tt  tt   nn   nm   tp  tpp  ss  ss   d   tch   tch   tch'  tk'  tt'  tp'  t'h  t
l        lg  lkk  ll  ld  ltt  ll   lm   lb  lbb  ls  lss  r   lj    lch   lch'  lk'  lt'  lp'  rh   l
lg       lkk lkk  ngn ltt ltt  ll   lngm lkb lkbb lks lkss lg  lkj   lktch lkch' lk'  lkt' lkp' lk'  lk
lm       lmk lmkk lmn lmd lmdd lmn  lmm  lb  lbb  lms lmss lm  lmj   lmch  lmch' lmk' lmt' lmp' lmh  lm
lb       lbk lbkk lmn lbd lbdd lmn  lmm  lb  lbb  lbs lbss lb  lbj   lbch  lbch' lbk' lbt' lbp' lbh  lp
ls       ltk ltkk ll  ltt ltt  ll   lm   lpp lpp  lss lss  ls  ltch  ltch  lch'  lk'  lt'  lp'  lt'  lt
lt       ltk ltkk ll  ltt ltt  ll   lm   lpp lpp  lss lss  lt  ltch  ltch  ltch' ltk' lt'  lp'  lt'  lt
lp       lpg lpkk lmn lpd lptt lmn  lmm  lbb lbb  lps lpss lp' lpj   lptch lpch' lpk' lpt' lp'  lp'  lp'
lh       lk' lkk  ll  lt' ltt  ll   lm   lp' lpp  ls  lss  lh  lch'  ltch  lch'  lk'  lt'  lp'  lh   l
m        mg  mkk  mn  md  mdd  mn   mm   mb  mbb  ms  mss  m   mj    mch   mch'  mk'  mt'  mp'  mh   m
b        pk  pkk  mn  pt  ptt  mn   mm   pp  pp   ps  pss  b   pch   ptch  pch'  pk'  pt'  pp'  p'h  p
bs       pkk pkk  mn  ptt ptt  mn   mm   pp  pp   pss pss  ps  ptch  ptch  ptch' pk'  pt'  pp'  pt'  p
s        tk  tkk  nn  tt  tt   nn   nm   tp  tpp  ss  ss   s   tch   tch   tch'  tk'  tt'  tp'  t'h  t
ss       tk  tkk  nn  tt  tt   nn   nm   tp  tpp  ss  ss   ss  tch   tch   tch'  tk'  tt'  tp'  t'h  t
_        g   kk   n   d   dd   r    m    b   bb   s   ss   _   j     jj    ch'   k'   t'   p'   h    _
ng       ngg nkk  ngn ngd ngdd ngn  ngm  ngb ngbb ngs ngss ng  ngj   ngjj  ngch' ngk' ngt' ngp' ngh  ng
j        tk  tkk  nn  tt  tt   nn   nm   tp  tpp  ss  ss   j   tch   tch   tch'  tk'  tt'  tp'  ch'  t
ch       tk  tkk  nn  tt  tt   nn   nm   tp  tpp  ss  ss   ch' tch   tch   tch'  tk'  tt'  tp'  ch'  t
k        kk  kk   ngn kt  ktt  ngn  ngm  kp  kpp  ks  kss  k'  kch   ktch  kch'  kk'  kt'  kp'  k'h  k
t        tk  tkk  nn  tt  tt   nn   nm   tp  tpp  ss  ss   t'  tch   tch   tch'  tk'  tt'  tp'  t'h  t
p        pk  pkk  mn  pt  ptt  mn   mm   pp  pp   ps  pss  p'  pch   ptch  pch'  pk'  pt'  pp'  p'h  p
h        k'  kk   nn  t'  tt   l    m    p'  pp   hs  hss  h   ch'   tch   ch'   k'   t'   p'   h    t
