# Box4Pets Mobile — Redesign 2026-05

Resumo das alterações feitas no app durante o ciclo de redesign.

## Objetivo

Migrar o app de um layout "antigo" (Figma não bem replicado) para uma identidade visual moderna, profissional, fluida e com mais animações nativas — mantendo todas as integrações existentes com Airtable, OneSignal, GetStorage etc.

---

## 1. Setup de desenvolvimento

- Flutter SDK 3.41.9 + Dart 3.11.5 instalados.
- Xcode 26.5, assinatura via Personal Team (Apple ID `erichprates@yahoo.com.br` / "CARLITO PAES").
- Bundle ID de dev: `com.erichprates.box4pets.dev`.
- Deploy testado em:
  - Simulator iPhone 17 Pro (`9BA077A5-BDFA-426E-B08C-C75704769885`)
  - iPhone físico de Erich (`00008140-001A60381407001C`)
- OneSignal `initialize` comentado em `lib/main.dart` enquanto a conta é Personal Team (não tem entitlement push).

## 2. Tipografia e tema

- `pubspec.yaml`: `google_fonts` ativo.
- `lib/src/Box4PetsApp.dart`: theme com `GoogleFonts.archivoTextTheme()` como base; `displayLarge`, `displayMedium`, `displaySmall`, `headlineLarge`, `headlineMedium`, `headlineSmall` em `GoogleFonts.dmSans`.
- Cor primária `AppColor.primary` = `#3F2873` (substitui o roxo antigo `#600499`); secundária `#00A7C8`; laranja CTA `#FF7900`.
- `assets/logoB4p.svg`: todos os fills `#600499` trocados por `#3F2873` para casar com botões e tema.

## 3. Splash / Fluxo de entrada

- `flutter_native_splash.yaml` configurado com `background_image: assets/images/splash.png` (1284×2778).
- Slider de primeiro acesso removido — `splash_page.dart` vai direto para `/login` (sem user) ou `/base` (com user) com transição em fade (420ms) ou `WelcomePageRoute` (slide up 520ms).
- `lib/core/ui/widgets/welcome_transition.dart`: `WelcomePageRoute<T>` com slide vertical (offset 0.06 → 0) em `easeOutCubic`. Substitui o `popAndPushNamed` áspero do login → home.

## 4. Background e widgets reutilizáveis

- `lib/core/ui/widgets/parallax_background.dart`: gradiente base `#F8F5FF → #FDFCFF` com camada `assets/circles.png` deslocada por accelerometer (low-pass filter via Ticker).
- `lib/core/ui/widgets/shimmer.dart` (novo):
  - `Shimmer` — `ShaderMask` animado, gradiente lilás varrendo a cada 1.4s.
  - `ShimmerBox` — Container com cor `#E7DDF8` envolvido em Shimmer.
  - `SmartNetworkImage` — Stack com ShimmerBox + `Image.network` com `frameBuilder` fade-in 320ms; `errorBuilder` mostra ícone discreto.
- `lib/core/ui/widgets/box_4_pets_loader.dart`: loader padronizado (Lottie `Moody Dog.json` 140×140) — `Padding(bottom: 110) + Center` por default (compensa o overlay do bottom nav e cai sempre no mesmo centro visual da tela); `inline: true` para usos dentro de Column com texto abaixo.

## 5. Navegação (base)

- `lib/src/pages/base/base.dart`:
  - SideMenu antigo removido.
  - Bottom nav glass blur (`BackdropFilter` + `Material(type: MaterialType.transparency)` para evitar sublinhado amarelo de debug).
  - 4 itens, na ordem: **Início · Descubra · Doenças & Traços · Perfil** (Doenças & Traços é launcher — abre `TracosFiltroPage`).
  - Body via Map `{0: Home, 1: Destaques, 3: Profile}[_selectedIndex]`.

## 6. Home (`home.dart`)

- Tabs glass "Em análise / Resultados" com pill animada.
- Pet strip horizontal com avatares circulares + auto-center no tap.
- Pet focado em `_GlassCard` com `_petActionPill` (flex 3 Traços, flex 2 Raças/Outros), pílulas com gradiente de cor por ação.
- Carousel de destaques (blog) em Stack manual com z-ordering, título 31pt DM Sans 4 linhas, gradiente preto stops `[0.2, 0.6, 1.0]`.
- Empty states glass (`_buildEmptyPetCard`, `_buildEmptyFilterCard`).
- Loading: quando bloc em `AppAtivacaoLoading`, retorna `Box4PetsLoader` como corpo inteiro.
- **`_padWithDemo` removido** (era dev-only para simular múltiplos pets).

## 7. Descubra (`destaques/`)

- Aba "Conteúdo" renomeada para "Descubra".
- `_FeaturedCard` com parallax interno (imagem translada 35% do swipe) em Stack com `SmartNetworkImage`.
- Chips de categoria compactas (transparente / preenchimento primário).
- 6 itens mais recentes por padrão; "Ver mais" → `ViewMore` com paginação 8 + 8 a cada scroll-near-bottom (350ms debounce), com `_LoadMoreButton` e `_LoadingDots`.
- `screen_expanded.dart`: header com parallax, ClipRRect overlap, swipe-down-to-dismiss com AnimationController de retorno. Hero tag = `destaque-${item.id}` (não título, evita colisões).

## 8. Perfil (`profile/`)

- Avatar com ring gradient (primary→secondary) + badge câmera.
- `image_picker` para câmera/galeria; persistência via `GetStorage` key `profile_photo_path`.
- Modais bottom-sheet para editar perfil e alterar senha.

## 9. Ativação (`ativacao/`)

- Título centralizado, seções glass: Pet / Medidas / Identificação / Teste.
- Segmented controls para Espécie, Sexo, KG/G, Meses/Anos.
- Bottom sheets com busca para raça e picker de teste.

## 10. Login & Cadastro

- `login.dart`: imagem fixa de fundo `assets/images/login_bg.png` (baixada de `box4pets.com.br/cdn/shop/files/DSC09921_360x.png`), SVG branco do logo sobreposto; form card branco rolando sobre. Após auth → `WelcomePageRoute(Base())` via `pushAndRemoveUntil((_) => false)`. Loaders dentro de botões removidos (a pedido — só texto "Entrando...").
- `register.dart`: seções glass (Conta · Contato · Endereço · Função), CEP autocompletar via viacep, picker de Função.

## 11. Resultados — Raças (`teste_racas/`)

- `teste_raca.dart`:
  - `fl_chart` PieChart com **sweep animation** entrada via `ClipPath` (`_SweepClipper`, `TweenAnimationBuilder` 1300ms easeInOutCubic).
  - Toque numa fatia cresce ela e mostra % + nome da raça no centro.
  - Legenda custom abaixo, alinhada à esquerda (sem truncamento).
  - Pílula "Compartilhar" laranja glass (substituiu o chevron).
- `gerar_pdf_racas.dart`: PDF do gráfico via screenshot dentro de Container branco com top padding 50px (evita corte), `pw.NewPage()` antes de "Sobre o Painel Origem".
- `view_raca.dart`: nome + região da raça sobreposto na foto (com `Material(transparency)` + `TextDecoration.none` pra evitar sublinhado amarelo no Hero); grid 2x2 de stats; modal "Você sabia?" laranja com texto branco.

## 12. Resultados — Traços & Doenças (`tracos_doencas/`)

- 4 quadros glass com count-up animation; números formatados com `padLeft(2, '0')` (`01` em vez de `1`); 59pt DM Sans.
- Fluxos separados:
  - **Resultado Completo** → `Resultado_<name>.pdf`
  - **Certificado** → `Certificado_<name>.pdf`
- State tracking: `_resultadoGenerated`, `_resultadoPath`, `_isGeneratingResultado`, `_certGenerated`, `_certPath`, `isCertificado`, `_certCurrent`, `_certTotal`.
- Share button → bottom sheet escolhe Relatório/Certificado.
- Callbacks `onProgress(current, total)` e `onComplete(path)` adicionados a `shared_certificado.dart` e `shared_component.dart`.
- `_showReadyDialog` usa `appNavigatorKey` global para popup mesmo se o usuário trocou de página durante a geração.

## 13. Doenças & Traços (filtro)

- `lib/src/pages/tracos_filtro/views/tracos_filtro.dart`: WebView para `https://filtrobox4pets.netlify.app`.
- Loader `Positioned.fill(child: Box4PetsLoader())` quando `_progress < 0.15`.

## 14. PDF viewer (`pdf_viwer_page.dart`)

- Header glass com back + título "Resultado" + share button.
- `Box4PetsLoader` durante load do documento.

## 15. Estabilidade / models

- `lib/src/pages/login/models/user_auth_model.dart` e `lib/src/pages/ativacao/models/user_activation_model.dart`: `fromMap` tolerante a campos null (`(v ?? '').toString()`). Antes, Criadores sem Telefone/Endereço crashavam no `as String` e travavam home.
- `lib/src/pages/home/bloc/app_ativacao_bloc.dart`: cada `await` em try/catch; em qualquer erro de rede emite `AppAtivacaoLoaded(appAtivacao: [], ...)` em vez de ficar preso em `AppAtivacaoLoading`. Validação `response.data is Map && response.data['records'] is List` antes do cast.

## 16. Correções de UX/visual

- **Sublinhado amarelo de debug em textos**: causa = `Text` fora da árvore `Material`. Envolvidos em `Material(type: MaterialType.transparency)`:
  - `base.dart` `_ModernBottomNav`
  - `home.dart` `_buildCarouselCard` (Hero)
  - `destaques.dart` `_FeaturedCard` e `_HorizontalCard` (Hero)
  - `screen_expanded.dart` (Hero destino)
  - `view_raca.dart` (nome sobre foto)
- **Cinza escuro feio durante carregamento de foto** (4 lugares): substituído `Colors.grey.shade300` por `Color(0xFFE7DDF8)` (lilás).
- **Skeleton/shimmer** aplicado em todos os cards com imagem: home carousel, pet avatars, descubra featured + horizontal cards, view_more grid card, screen_expanded header.
- **Bug Hero "destaque-${titulo}"**: trocado para `destaque-${item.id}` (títulos duplicados quebravam o Hero).
- **PDF chart cropping**: Container branco + 50px top padding *dentro* do Screenshot.
- **Loaders dentro de botões removidos** (a pedido) — só texto.

## 17. Loader padronizado

- Tamanho 140×140 em todas as telas (antes 140/160 misturados).
- Posição: sempre centralizado vertical/horizontalmente no corpo, com bias 110px pra cima pra compensar o overlay do bottom nav.
- Telas que retornam loader como corpo (Home, Destaques, Profile, Traços & Doenças, Teste Raça, PDF Viewer, Tracos): `if (state is XxxLoading) return const Box4PetsLoader();`.
- Telas com loader dentro de Stack (`tracos_filtro`): envolvido em `Positioned.fill`.
- Loader inline (com texto abaixo): `Box4PetsLoader(inline: true)` em `doencas_uma_variante`.

## 18. Transição login → app

- Antes: `Navigator.popAndPushNamed(context, '/base')` (slide iOS abrupto, e mostrava splash no meio).
- Agora: `pushAndRemoveUntil(WelcomePageRoute(page: const Base()), (_) => false)` — slide vertical opaco 520ms, sem revelar telas atrás.

---

## Arquivos novos

- `lib/core/ui/widgets/welcome_transition.dart`
- `lib/core/ui/widgets/shimmer.dart`
- `lib/src/pages/tracos_filtro/views/tracos_filtro.dart`
- `flutter_native_splash.yaml`
- `CHANGELOG_REDESIGN.md` (este arquivo)

## Como rodar

```bash
flutter pub get
flutter run -d <device-id>     # device-id via `flutter devices`
```

Em dev usamos um FIFO em `/tmp/box4pets_cmd` para hot reload (`r`) / restart (`R`) / quit (`q`) sem precisar interagir com o terminal.

## Removido (dev-only)

- `kDemoFillCount` / `_padWithDemo` em `home.dart` — clonava o pet real até 15 entradas pra testar visual com vários pets. Removido neste commit.

---

# Iteração 2 — Nativos do iOS

## 19. Localização PT-BR

- Adicionado `flutter_localizations` no `pubspec.yaml`.
- `Box4PetsApp.dart`: `locale: Locale('pt','BR')`, `supportedLocales` e `localizationsDelegates` (Material/Widgets/Cupertino).
- Efeito: meses, dias da semana, botões "Cancelar/OK" dos widgets nativos vêm em PT-BR.
- Removido `syncfusion_flutter_charts` do pubspec (não era usado em código, e tinha conflito de versão com `intl 0.20.2` exigido pelo `flutter_localizations`).

## 20. Calendário nativo iOS

- `_pickDate` em `activation.dart`: substituído `showDatePicker` Material por `showCupertinoModalPopup` + `CupertinoDatePicker` (modo `date`, ordem dia/mês/ano, faixa 1900–2100).
- Modal envelopado em `Material(type: MaterialType.transparency)` para evitar sublinhado amarelo de debug nos Texts; fontSize fixo 15 no header (Cancelar / título "Data de nascimento" / OK roxo).

## 21. Transições de página nativas

- `Box4PetsApp.dart`: `pageTransitionsTheme` com `CupertinoPageTransitionsBuilder` para `TargetPlatform.iOS` e `.macOS`.
- Efeito: toda navegação stack agora usa o slide-from-right com parallax do iOS e **suporta swipe-back gesture** (arrastar da borda esquerda pra voltar).
- Telas "tarefa" (Ativação, Cadastro) usam `CupertinoPageRoute(fullscreenDialog: true, ...)` — sobem de baixo pra cima estilo modal Apple (ex: "Compose new email"):
  - `app_bar_custom.dart` (botão "+" → Ativação)
  - `login.dart` (link "Criar conta" → Cadastro)

## 22. Pickers em roleta

- `lib/core/ui/widgets/cupertino_wheel_picker.dart` (novo): helper `showCupertinoWheelPicker({title, items, selected})` — retorna o item selecionado ou `null` se cancelado. Header com Cancelar / título / OK no estilo do app, e `CupertinoPicker` (wheel rolante) embaixo.
- Aplicado em:
  - **Teste** (Ativação)
  - **Função** (Cadastro)
  - **Função** (Editar perfil)
- Raça **permanece como bottom sheet com busca** (~300 opções, busca é UX crítica ali).

## 23. CupertinoAlertDialog

- **Update do app** (home `_openModalVersion`): trocado `AlertDialog` Material por `CupertinoAlertDialog` com `CupertinoDialogAction(isDefaultAction: true)` no botão "Atualizar".
- **Confirmação de Sair** (perfil `_logout`): antes era logout direto. Agora pede confirmação com `CupertinoAlertDialog` e ação destrutiva (`isDestructiveAction: true`) — "Sair" em vermelho do iOS.

## 24. Botão Ativar

- Em `activation.dart`, `_SubmitButton` no `Positioned`:
  - Antes: `left: 20, right: 20` (largura total).
  - Agora: `left: 20, right: width * 0.15` (15% de margem na direita, botão recuado).
  - Altura: 56 → 62 (+10%).

## 25. Box4PetsLoader padronizado (revisitado)

- Versão final: `Padding(bottom: 110, child: Center(SizedBox(140, lottie)))`.
- O `bottom: 110` compensa o overlay do bottom nav nas telas com tabs (Home/Descubra/Perfil), fazendo o cachorrinho cair no **centro visual** independente de qual aba estiver.
- Telas com loader como corpo único: retornam `Box4PetsLoader()` diretamente (Center fill).
- Loader inside Stack (`tracos_filtro`): envolvido em `Positioned.fill`.
- Loader inline com texto abaixo (`doencas_uma_variante`): `Box4PetsLoader(inline: true)`.

## 26. Estabilidade adicional

- `app_ativacao_bloc.dart`: cada `await` em try/catch — em qualquer erro de rede emite `AppAtivacaoLoaded(appAtivacao: [], ...)`. Antes ficava preso em `AppAtivacaoLoading` (Criador sem pets travava infinitamente).
- `user_auth_model.dart` e `user_activation_model.dart`: `fromMap` usa `(v ?? '').toString()` em cada campo — tolera Telefone/Endereço null no Airtable (comum em Criadores).

## 27. Performance/UX

- Splash → Login: fade 420ms (`PageRouteBuilder`).
- Login → Base: `WelcomePageRoute` com slide vertical 6% → 0, 520ms easeOutCubic, opaco desde o início (sem revelar splash atrás).

---

## Arquivos novos (Iteração 2)

- `lib/core/ui/widgets/cupertino_wheel_picker.dart`

## Dependências

```yaml
+ flutter_localizations:    # SDK
- syncfusion_flutter_charts: ^22.2.11   # removido (não usado)
```
