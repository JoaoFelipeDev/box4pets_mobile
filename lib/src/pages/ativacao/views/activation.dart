import 'dart:convert';
import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:Box4Pets/core/ui/widgets/cupertino_wheel_picker.dart';
import 'package:Box4Pets/core/ui/widgets/parallax_background.dart';
import 'package:Box4Pets/src/pages/ativacao/bloc/activation_bloc.dart';
import 'package:Box4Pets/src/pages/ativacao/models/activation_model.dart';
import 'package:Box4Pets/src/pages/ativacao/models/racas_model.dart';
import 'package:Box4Pets/src/pages/ativacao/models/user_activation_model.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class Activation extends StatefulWidget {
  const Activation({Key? key}) : super(key: key);

  @override
  State<Activation> createState() => _ActivationState();
}

const List<String> species = ["Canina", "Felina"];
const List<String> sexo = ["Macho", "Fêmea"];
const List<String> testes = [
  'Origem: Identificação de Raças - Cães',
  'Saúde - Identificação de Doenças Genéticas',
  'Painel Saúde + Painel Origem',
  'Painel de Raça Específica',
  'Teste Único',
  'Perfil de DNA',
  'Teste Genético ALKC RI (registro inicial): Identificação de Raça - Origem',
  'Teste Genético ALKC: Identificação de Doenças, Traços e Perfil de DNA',
];

class _ActivationState extends State<Activation> {
  final box = GetStorage();
  String valueMedida = 'KG';
  String valueIdade = 'Meses';
  String textDataNascimento = 'Selecionar data';
  final TextEditingController nomePet = TextEditingController();
  final TextEditingController controllerIdade = TextEditingController();
  final TextEditingController controllerSwab = TextEditingController();
  final TextEditingController controllerRegistro = TextEditingController();
  final TextEditingController controllerMicrochip = TextEditingController();
  final controllerData = MaskedTextController(mask: '00/00/0000');
  final controllerPeso = MaskedTextController(mask: '000');
  String speciesValue = species.first;
  String testeValue = testes.first;
  String racasValue = '';
  String racasCatValue = '';
  String sexoValue = sexo.first;
  late final ActivationBloc _activationBloc;
  List<RacasModel> racas = [];
  List<RacasModel> racasCat = [];
  String _textDataNascimento = '';

  @override
  void initState() {
    super.initState();
    _activationBloc = ActivationBloc()..add(ActivationGetRacas());
  }

  @override
  void dispose() {
    _activationBloc.close();
    nomePet.dispose();
    controllerIdade.dispose();
    controllerSwab.dispose();
    controllerRegistro.dispose();
    controllerMicrochip.dispose();
    controllerData.dispose();
    controllerPeso.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    initializeDateFormatting();
    return DateFormat.yMd().format(dateTime);
  }

  String _formatDateTimeText(DateTime dateTime) {
    initializeDateFormatting();
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColor.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void processoDeAtivacao() {
    final json = box.read('user');
    final user = UserActivationModel.fromJson(jsonDecode(json));
    final registro =
        controllerRegistro.text.isNotEmpty ? controllerRegistro.text : 'Não';
    final chip =
        controllerMicrochip.text.isNotEmpty ? controllerMicrochip.text : 'Não';
    final nome = nomePet.text;
    final idade = controllerIdade.text;
    final peso = controllerPeso.text;
    final swab = '${controllerSwab.text}_$nome';

    if (nome.isEmpty) return _showError('Digite o nome do seu pet');
    if (idade.isEmpty) return _showError('Digite a idade do seu pet');
    if (peso.isEmpty) return _showError('Digite o peso do seu pet');
    if (_textDataNascimento.isEmpty) {
      return _showError('Selecione a data de nascimento');
    }
    if (controllerSwab.text.isEmpty) return _showError('Digite o SWAB');

    final data = ActivationModel(
      dataNascimento: _textDataNascimento,
      case_ID: swab,
      especie: speciesValue,
      raca: speciesValue == 'Canina' ? racasValue : racasCatValue,
      sexo: sexoValue,
      namePet: nome,
      idade: '$idade - $valueIdade',
      peso: valueMedida == "KG"
          ? peso
          : ((int.parse(peso) / 100) * 100).toString(),
      email: user.email,
      name: user.name,
      perfil: user.perfil,
      phone: user.telefone,
      email_app_usuario: user.id,
      testes: testeValue,
      chip: chip,
      registro: registro,
      swab: controllerSwab.text,
    );

    HapticFeedback.mediumImpact();
    _activationBloc.add(ActivationUser(activation: data));
  }

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    DateTime tempPicked = DateTime.now();
    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (ctx) {
        return Material(
          type: MaterialType.transparency,
          child: Container(
            height: 320,
            color: CupertinoColors.systemBackground.resolveFrom(ctx),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoColors.separator.resolveFrom(ctx),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColor.primary.withOpacity(0.7),
                            ),
                          ),
                        ),
                        Text(
                          'Data de nascimento',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primary,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              Navigator.of(ctx).pop(tempPicked),
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColor.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: DateTime.now(),
                      minimumDate: DateTime(1900),
                      maximumDate: DateTime(2100),
                      dateOrder: DatePickerDateOrder.dmy,
                      onDateTimeChanged: (d) => tempPicked = d,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        textDataNascimento = _formatDateTimeText(picked);
        _textDataNascimento = _formatDateTime(picked);
      });
    }
  }

  Future<void> _pickRaca() async {
    final isDog = speciesValue == 'Canina';
    final list = isDog ? racas : racasCat;
    if (list.isEmpty) return;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RacaPickerSheet(
        racas: list,
        selected: isDog ? racasValue : racasCatValue,
      ),
    );
    if (selected != null) {
      setState(() {
        if (isDog) {
          racasValue = selected;
        } else {
          racasCatValue = selected;
        }
      });
    }
  }

  Future<void> _pickTeste() async {
    final selected = await showCupertinoWheelPicker(
      context: context,
      title: 'Teste',
      items: testes,
      selected: testeValue,
    );
    if (selected != null) {
      setState(() => testeValue = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ParallaxBackground(
        child: BlocListener<ActivationBloc, ActivationState>(
          bloc: _activationBloc,
          listener: (context, state) {
            if (state is ActivationRacasLoaded) {
              setState(() {
                racasValue = state.racasDog[0].racas;
                racasCatValue = state.racasCat[0].racas;
                racas = state.racasDog;
                racasCat = state.racasCat;
              });
            }
          },
          child: BlocBuilder<ActivationBloc, ActivationState>(
            bloc: _activationBloc,
            builder: (context, state) {
              if (state is ActivationLoaded) {
                return _buildSuccess();
              }
              return _buildForm(state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColor.primary, AppColor.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withOpacity(0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 48),
            )
                .animate()
                .scale(
                    begin: const Offset(0.7, 0.7),
                    duration: 420.ms,
                    curve: Curves.easeOutBack)
                .fadeIn(),
            const SizedBox(height: 22),
            Text(
              'Ativação concluída',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: AppColor.primary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -28 * 0.04,
              ),
            ).animate(delay: 120.ms).fadeIn(duration: 320.ms),
            const SizedBox(height: 12),
            Text(
              'Em até 24h úteis você receberá no seu e-mail o código de postagem.',
              textAlign: TextAlign.center,
              style: GoogleFonts.archivo(
                color: AppColor.primary.withOpacity(0.7),
                fontSize: 14,
                height: 1.5,
              ),
            ).animate(delay: 180.ms).fadeIn(duration: 320.ms),
            const SizedBox(height: 6),
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                style: GoogleFonts.archivo(
                  color: AppColor.primary.withOpacity(0.55),
                  fontSize: 12.5,
                  height: 1.5,
                ),
                text: 'Se não receber, confira o SPAM ou fale com a gente: ',
                children: [
                  TextSpan(
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColor.primary),
                    text: 'contato@box4pets.com.br',
                  ),
                ],
              ),
            ).animate(delay: 240.ms).fadeIn(duration: 320.ms),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/base'),
                child: Text(
                  'Voltar ao início',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ).animate(delay: 320.ms).fadeIn(duration: 320.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(ActivationState state) {
    final isLoading = state is ActivationLoading;
    return Stack(
      children: [
        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Ativar swab',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          color: AppColor.primary,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -30 * 0.04,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Preencha os dados do pet pra iniciar o teste',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.archivo(
                          color: AppColor.primary.withOpacity(0.55),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.1, end: 0),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _Section(
                      title: 'Pet',
                      children: [
                        _Field(
                          controller: nomePet,
                          label: 'Nome do pet',
                          icon: Icons.pets_rounded,
                        ),
                        _SegmentedField(
                          label: 'Espécie',
                          icon: Icons.category_rounded,
                          options: species,
                          value: speciesValue,
                          onChanged: (v) => setState(() => speciesValue = v),
                        ),
                        _PickerField(
                          label: 'Raça',
                          icon: Icons.style_rounded,
                          value: speciesValue == 'Canina'
                              ? racasValue
                              : racasCatValue,
                          placeholder: 'Selecionar raça',
                          onTap: _pickRaca,
                        ),
                        _SegmentedField(
                          label: 'Sexo',
                          icon: Icons.transgender_rounded,
                          options: sexo,
                          value: sexoValue,
                          onChanged: (v) => setState(() => sexoValue = v),
                        ),
                        _PickerField(
                          label: 'Data de nascimento',
                          icon: Icons.cake_outlined,
                          value: _textDataNascimento.isEmpty
                              ? ''
                              : textDataNascimento,
                          placeholder: 'Selecionar data',
                          onTap: _pickDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _Section(
                      title: 'Medidas',
                      children: [
                        _NumberWithUnitField(
                          controller: controllerPeso,
                          label: 'Peso',
                          icon: Icons.monitor_weight_outlined,
                          unit: valueMedida,
                          units: const ['KG', 'G'],
                          onUnitChanged: (v) =>
                              setState(() => valueMedida = v),
                        ),
                        _NumberWithUnitField(
                          controller: controllerIdade,
                          label: 'Idade',
                          icon: Icons.timelapse_rounded,
                          unit: valueIdade,
                          units: const ['Meses', 'Anos'],
                          onUnitChanged: (v) =>
                              setState(() => valueIdade = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _Section(
                      title: 'Identificação',
                      children: [
                        _Field(
                          controller: controllerSwab,
                          label: 'SWAB',
                          icon: Icons.qr_code_2_rounded,
                        ),
                        _Field(
                          controller: controllerRegistro,
                          label: 'Nº de registro (opcional)',
                          icon: Icons.app_registration_rounded,
                          optional: true,
                        ),
                        _Field(
                          controller: controllerMicrochip,
                          label: 'Nº de microchip (opcional)',
                          icon: Icons.memory_rounded,
                          optional: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _Section(
                      title: 'Teste adquirido',
                      children: [
                        _PickerField(
                          label: 'Teste',
                          icon: Icons.science_outlined,
                          value: testeValue,
                          placeholder: 'Selecionar teste',
                          onTap: _pickTeste,
                          twoLines: true,
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 6,
          left: 14,
          child: _GlassBackButton(
            onTap: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          bottom: 18,
          left: 20,
          right: MediaQuery.of(context).size.width * 0.15,
          child: _SubmitButton(
            loading: isLoading,
            onTap: processoDeAtivacao,
          ),
        ),
      ],
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GlassBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColor.primary, size: 16),
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _SubmitButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 62,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColor.primary,
                  AppColor.primary.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withOpacity(0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: Box4PetsLoader(size: 28),
                    )
                  : Text(
                      'Ativar',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: AppColor.primary.withOpacity(0.55),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool optional;
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        cursorColor: AppColor.primary,
        style: GoogleFonts.archivo(
          color: AppColor.primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF3EEFC).withOpacity(0.7),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10, right: 6),
            child:
                Icon(icon, color: AppColor.primary.withOpacity(0.6), size: 18),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          hintText: label,
          hintStyle: TextStyle(
            color: AppColor.primary.withOpacity(0.45),
            fontWeight: FontWeight.w500,
            fontSize: 13.5,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColor.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _SegmentedField extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;
  const _SegmentedField({
    required this.label,
    required this.icon,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 6),
            child: Row(
              children: [
                Icon(icon, color: AppColor.primary.withOpacity(0.6), size: 14),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColor.primary.withOpacity(0.65),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EEFC).withOpacity(0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                for (final opt in options)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onChanged(opt);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        height: 38,
                        decoration: BoxDecoration(
                          color: opt == value
                              ? AppColor.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: opt == value
                              ? [
                                  BoxShadow(
                                    color: AppColor.primary.withOpacity(0.22),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          opt,
                          style: TextStyle(
                            color: opt == value
                                ? Colors.white
                                : AppColor.primary.withOpacity(0.7),
                            fontWeight: opt == value
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 12.5,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String placeholder;
  final VoidCallback onTap;
  final bool twoLines;
  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.twoLines = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EEFC).withOpacity(0.7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: AppColor.primary.withOpacity(0.6), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColor.primary.withOpacity(0.55),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasValue ? value : placeholder,
                      maxLines: twoLines ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.archivo(
                        color: hasValue
                            ? AppColor.primary
                            : AppColor.primary.withOpacity(0.45),
                        fontWeight: hasValue
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 13.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColor.primary.withOpacity(0.45), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberWithUnitField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String unit;
  final List<String> units;
  final ValueChanged<String> onUnitChanged;
  const _NumberWithUnitField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.unit,
    required this.units,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              cursorColor: AppColor.primary,
              style: GoogleFonts.archivo(
                color: AppColor.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF3EEFC).withOpacity(0.7),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 14),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 6),
                  child: Icon(icon,
                      color: AppColor.primary.withOpacity(0.6), size: 18),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0),
                hintText: label,
                hintStyle: TextStyle(
                  color: AppColor.primary.withOpacity(0.45),
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColor.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEFC).withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  for (final u in units)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onUnitChanged(u);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: u == unit
                                ? AppColor.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(
                            u,
                            style: TextStyle(
                              color: u == unit
                                  ? Colors.white
                                  : AppColor.primary.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: u == unit
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RacaPickerSheet extends StatefulWidget {
  final List<RacasModel> racas;
  final String selected;
  const _RacaPickerSheet({required this.racas, required this.selected});

  @override
  State<_RacaPickerSheet> createState() => _RacaPickerSheetState();
}

class _RacaPickerSheetState extends State<_RacaPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.racas
        .where((r) => r.racas.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  children: [
                    Text(
                      'Selecione a raça',
                      style: GoogleFonts.dmSans(
                        color: AppColor.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF3EEFC),
                    hintText: 'Buscar raça',
                    prefixIcon: Icon(Icons.search,
                        color: AppColor.primary, size: 20),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final r = filtered[index].racas;
                    final isSelected = r == widget.selected;
                    return InkWell(
                      onTap: () => Navigator.pop(context, r),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                r,
                                style: GoogleFonts.archivo(
                                  color: AppColor.primary,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_rounded,
                                  color: AppColor.primary, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

