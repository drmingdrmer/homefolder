XPTemplate priority=all

let s:f = g:XPTfuncs()

XPTvar $TIME_FMT     '%H:%M:%S'

call XPTdefineSnippet("Now", {}, "`time()^")

" [u]nicode [m]ath _ for subscript

call XPTdefineSnippet("um_a", {}, "ₐ")
call XPTdefineSnippet("um_e", {}, "ₑ")
call XPTdefineSnippet("um_o", {}, "ₒ")
call XPTdefineSnippet("um_x", {}, "ₓ")

call XPTdefineSnippet("um_inve", {}, "ₔ")

call XPTdefineSnippet("um_0", {}, "₀")
call XPTdefineSnippet("um_1", {}, "₁")
call XPTdefineSnippet("um_2", {}, "₂")
call XPTdefineSnippet("um_3", {}, "₃")
call XPTdefineSnippet("um_4", {}, "₄")
call XPTdefineSnippet("um_5", {}, "₅")
call XPTdefineSnippet("um_6", {}, "₆")
call XPTdefineSnippet("um_7", {}, "₇")
call XPTdefineSnippet("um_8", {}, "₈")
call XPTdefineSnippet("um_9", {}, "₉")

call XPTdefineSnippet("um_add",          {}, "₊")
call XPTdefineSnippet("um_sub",          {}, "₋")
call XPTdefineSnippet("um_eq",           {}, "₌")
call XPTdefineSnippet("um_lparentheses", {}, "₍")
call XPTdefineSnippet("um_rparentheses", {}, "₎")

" [u]nicode [m]ath [sup]script

call XPTdefineSnippet("umsup0", {}, "⁰")
call XPTdefineSnippet("umsup1", {}, "¹")
call XPTdefineSnippet("umsup2", {}, "²")
call XPTdefineSnippet("umsup3", {}, "³")
call XPTdefineSnippet("umsup4", {}, "⁴")
call XPTdefineSnippet("umsup5", {}, "⁵")
call XPTdefineSnippet("umsup6", {}, "⁶")
call XPTdefineSnippet("umsup7", {}, "⁷")
call XPTdefineSnippet("umsup8", {}, "⁸")
call XPTdefineSnippet("umsup9", {}, "⁹")
call XPTdefineSnippet("umsupi", {}, "ⁱ")
call XPTdefineSnippet("umsupn", {}, "ⁿ")

call XPTdefineSnippet("umsupadd",          {}, "⁺")
call XPTdefineSnippet("umsupsub",          {}, "⁻")
call XPTdefineSnippet("umsupeq",           {}, "⁼")
call XPTdefineSnippet("umsuplparentheses", {}, "⁽")
call XPTdefineSnippet("umsuprparentheses", {}, "⁾")

call XPTdefineSnippet("umall",   {}, "∀")
call XPTdefineSnippet("umexist", {}, "∃")
call XPTdefineSnippet("umelt", {}, "∈")


call XPTdefineSnippet("umempty",       {}, "∅")
call XPTdefineSnippet("umnoelt",       {}, "∉")
call XPTdefineSnippet("umsubset",      {}, "⊂")
call XPTdefineSnippet("umsubseteq",    {}, "⊆")
call XPTdefineSnippet("umsuperset",    {}, "⊃")
call XPTdefineSnippet("umsuperseteq",  {}, "⊇")
call XPTdefineSnippet("umnosubset",    {}, "⊄")
call XPTdefineSnippet("umintersect",   {}, "⋂")
call XPTdefineSnippet("umunion",       {}, "⋃")
call XPTdefineSnippet("umnoeq",        {}, "≠")
call XPTdefineSnippet("umle",          {}, "≤")
call XPTdefineSnippet("umge",          {}, "≥")
call XPTdefineSnippet("umalmosteq",    {}, "≈")
call XPTdefineSnippet("umidentical",   {}, "≡")
call XPTdefineSnippet("umstruckN",     {}, "ℕ")
call XPTdefineSnippet("umstruckZ",     {}, "ℤ")
call XPTdefineSnippet("umstruckC",     {}, "ℚ")
call XPTdefineSnippet("umstruckR",     {}, "ℝ")
call XPTdefineSnippet("umstruckC",     {}, "ℂ")
call XPTdefineSnippet("umceiling",     {}, "⌈`^⌉")
call XPTdefineSnippet("umfloor",       {}, "⌊`^⌋")
call XPTdefineSnippet("umsum",         {}, "∑")
call XPTdefineSnippet("umintegral",    {}, "∫")
call XPTdefineSnippet("umcirx",        {}, "⊗")
call XPTdefineSnippet("umcirplus",     {}, "⊕")
call XPTdefineSnippet("umcirdot",      {}, "⊙")
call XPTdefineSnippet("umpartialdiff", {}, "∂")
call XPTdefineSnippet("umroot",        {}, "√")
call XPTdefineSnippet("umcoloneq",     {}, "≔")
call XPTdefineSnippet("umplusminus",   {}, "±")
call XPTdefineSnippet("umsymbol",      {}, "ℵ")
call XPTdefineSnippet("uminf",         {}, "∞")
call XPTdefineSnippet("umprime",       {}, "′")
call XPTdefineSnippet("umdegree",      {}, "°")
call XPTdefineSnippet("umscriptl",     {}, "ℓ")
call XPTdefineSnippet("umnot",         {}, "¬")
call XPTdefineSnippet("umand",         {}, "∧")
call XPTdefineSnippet("umor",          {}, "∨")
call XPTdefineSnippet("umbecause",     {}, "∵")
call XPTdefineSnippet("umtherefore",   {}, "∴")

" [u]nicode [m]ath Greek alphabet

call XPTdefineSnippet("umAlpha",   {}, "Α")
call XPTdefineSnippet("umBeta",    {}, "Β")
call XPTdefineSnippet("umGamma",   {}, "Γ")
call XPTdefineSnippet("umDelta",   {}, "Δ")
call XPTdefineSnippet("umEpsilon", {}, "Ε")
call XPTdefineSnippet("umZeta",    {}, "Ζ")
call XPTdefineSnippet("umEta",     {}, "Η")
call XPTdefineSnippet("umTheta",   {}, "Θ")
call XPTdefineSnippet("umIota",    {}, "Ι")
call XPTdefineSnippet("umKappa",   {}, "Κ")
call XPTdefineSnippet("umLambda",  {}, "Λ")
call XPTdefineSnippet("umMu",      {}, "Μ")
call XPTdefineSnippet("umNu",      {}, "Ν")
call XPTdefineSnippet("umXi",      {}, "Ξ")
call XPTdefineSnippet("umOmicron", {}, "Ο")
call XPTdefineSnippet("umPi",      {}, "Π")
call XPTdefineSnippet("umRho",     {}, "Ρ")
call XPTdefineSnippet("umSigma",   {}, "Σ")
call XPTdefineSnippet("umTau",     {}, "Τ")
call XPTdefineSnippet("umUpsilon", {}, "Υ")
call XPTdefineSnippet("umPhi",     {}, "Φ")
call XPTdefineSnippet("umChi",     {}, "Χ")
call XPTdefineSnippet("umPsi",     {}, "Ψ")
call XPTdefineSnippet("umOmega",   {}, "Ω")
call XPTdefineSnippet("umalpha",   {}, "α")
call XPTdefineSnippet("umbeta",    {}, "β")
call XPTdefineSnippet("umgamma",   {}, "γ")
call XPTdefineSnippet("umdelta",   {}, "δ")
call XPTdefineSnippet("umepsilon", {}, "ε")
call XPTdefineSnippet("umzeta",    {}, "ζ")
call XPTdefineSnippet("umeta",     {}, "η")
call XPTdefineSnippet("umtheta",   {}, "θ")
call XPTdefineSnippet("umiota",    {}, "ι")
call XPTdefineSnippet("umkappa",   {}, "κ")
call XPTdefineSnippet("umlambda",  {}, "λ")
call XPTdefineSnippet("ummu",      {}, "μ")
call XPTdefineSnippet("umnu",      {}, "ν")
call XPTdefineSnippet("umxi",      {}, "ξ")
call XPTdefineSnippet("umomicron", {}, "ο")
call XPTdefineSnippet("umpi",      {}, "π")
call XPTdefineSnippet("umrho",     {}, "ρ")
call XPTdefineSnippet("umsigma",   {}, "σ")
call XPTdefineSnippet("umtau",     {}, "τ")
call XPTdefineSnippet("umupsilon", {}, "υ")
call XPTdefineSnippet("umphi",     {}, "φ")
call XPTdefineSnippet("umchi",     {}, "χ")
call XPTdefineSnippet("umpsi",     {}, "ψ")
call XPTdefineSnippet("umomega",   {}, "ω")

" Ϊ     Greek Capital Letter Iota with diaeresis
" Ϋ     Greek Capital Letter Upsilon with diaeresis

" ά     Greek Small Letter Alpha with acute accent
" έ     Greek Small Letter Epsilon with acute accent
" ή     Greek Small Letter Eta with acute accent
" ί     Greek Small Letter Iota with acute accent
" ΰ     Greek Small Letter Upsilon with diaeresis and acute accent

" ς     Greek Small Letter Final Sigma
" ϊ     Greek Small Letter Iota with diaeresis
" ϋ     Greek Small Letter Upsilon with diaeresis
" ό     Greek Small Letter Omicron with acute accent
" ύ     Greek Small Letter Upsilon with acute accent
" ώ     Greek Small Letter Omega with acute accent

XPT abcc
ω
