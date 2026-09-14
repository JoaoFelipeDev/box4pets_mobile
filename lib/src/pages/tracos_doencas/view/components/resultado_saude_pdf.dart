import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../ativacao/models/user_activation_model.dart';
import '../../../home/models/app_ativacao_model.dart';
import '../../models/list_doencas_pdf_model.dart';
import '../../models/list_tracos_pdf.dart';

const _purple = PdfColor.fromInt(0xFF3F2873);
const _teal = PdfColor.fromInt(0xFF00A7C8);
const _green = PdfColor.fromInt(0xFF1F9D55);
const _orange = PdfColor.fromInt(0xFFE67E22);
const _muted = PdfColor.fromInt(0xFF6B7280);
const _line = PdfColor.fromInt(0xFFE8E4F0);
const _text = PdfColor.fromInt(0xFF1F1633);

pw.Widget _checkIcon({double size = 9}) {
  return pw.SizedBox(
    width: size,
    height: size,
    child: pw.CustomPaint(
      size: PdfPoint(size, size),
      painter: (canvas, dim) {
        canvas
          ..setStrokeColor(_green)
          ..setLineWidth(1.35)
          ..setLineCap(PdfLineCap.round)
          ..setLineJoin(PdfLineJoin.round)
          ..moveTo(dim.x * 0.12, dim.y * 0.48)
          ..lineTo(dim.x * 0.38, dim.y * 0.22)
          ..lineTo(dim.x * 0.88, dim.y * 0.78)
          ..strokePath();
      },
    ),
  );
}

pw.Widget _warnIcon({double size = 9, required pw.Font bold}) {
  return pw.SizedBox(
    width: size,
    height: size,
    child: pw.Center(
      child: pw.Text(
        '!',
        style: pw.TextStyle(
          font: bold,
          fontSize: size,
          color: _orange,
          height: 1,
        ),
      ),
    ),
  );
}

pw.Widget _statusMark({
  required bool warning,
  required pw.Font bold,
  double size = 9,
}) {
  return warning ? _warnIcon(size: size, bold: bold) : _checkIcon(size: size);
}

bool _isClear(String? value) {
  final v = (value ?? '').trim().toLowerCase();
  return v.isEmpty ||
      v == '-' ||
      v == '—' ||
      v == 'nao detectada' ||
      v == 'não detectada' ||
      v == 'nao detectado' ||
      v == 'não detectado' ||
      v == 'nd';
}

String _geneOf(ListDoencasPdfModel d) {
  final gene = d.gene.trim();
  if (gene.isNotEmpty && gene != '-') return gene;
  return d.variante.trim();
}

String _achadoDescricao({required bool duasVariantes}) {
  return duasVariantes
      ? 'Duas variantes detectadas — risco aumentado para desenvolvimento da doença.'
      : 'Uma variante detectada — sem risco aumentado para desenvolvimento da doença.';
}

Future<Uint8List> buildResultadoSaudePdf({
  required Uint8List logoBytes,
  required String name,
  required AppAtivacaoModel ativacao,
  required UserActivationModel user,
  required List<ListDoencasPdfModel> umaVariante,
  required List<ListDoencasPdfModel> duasVariante,
  required List<ListDoencasPdfModel> principais,
  required List<ListDoencasPdfModel> todas,
  required List<ListTracosPdf> tracos,
}) async {
  final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Urbanist-Regular.ttf'));
  final medium = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Urbanist-Medium.ttf'));
  final semi = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Urbanist-SemiBold.ttf'));
  final bold =
      pw.Font.ttf(await rootBundle.load('assets/fonts/Urbanist-Bold.ttf'));

  final theme = pw.ThemeData.withFont(
    base: regular,
    bold: bold,
    italic: regular,
    boldItalic: bold,
  );

  final findingKeys = <String>{
    ...umaVariante.map((e) => e.marcador),
    ...duasVariante.map((e) => e.marcador),
    ...umaVariante.map((e) => e.doenca),
    ...duasVariante.map((e) => e.doenca),
  };

  bool isFinding(ListDoencasPdfModel d) =>
      findingKeys.contains(d.marcador) || findingKeys.contains(d.doenca);

  final tested = todas.isNotEmpty ? todas.length : principais.length;
  final risco = duasVariante.length;
  final portadores = umaVariante.length;
  final clear = (tested - portadores - risco).clamp(0, tested);

  final groupedTodas = _groupBy(
    todas.where((e) => e.doenca.trim().isNotEmpty && e.doenca != '-').toList(),
    (e) => e.categoria.trim().isEmpty ? 'Outros' : e.categoria.trim(),
  );
  final groupedTracos = _groupBy(
    tracos.where((e) => e.tracos.trim().isNotEmpty).toList(),
    (e) => e.categoria.trim().isEmpty ? 'Outros' : e.categoria.trim(),
  );

  final registro = (ativacao.registro ?? '').isEmpty ? 'Não' : ativacao.registro!;
  final chip = (ativacao.chip ?? '').isEmpty ? 'Não' : ativacao.chip!;
  final nascimento = ativacao.nascimento;
  final endereco = user.endereco.trim().isEmpty ? '' : ' — ${user.endereco}';

  final pdf = pw.Document(theme: theme);
  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 36),
        theme: theme,
      ),
      footer: (context) {
        if (context.pageNumber != context.pagesCount) {
          return pw.SizedBox();
        }
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 16),
          child: pw.Column(
            children: [
              pw.Text(
                'Resultados revisados e confirmados por Dr. Lucas Rodrigues, DVM, MS, PhD, CRMV-SP 15446.',
                style: pw.TextStyle(font: regular, fontSize: 8, color: _muted),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Este teste avalia variantes genéticas conhecidas; não substitui avaliação clínica veterinária.',
                style: pw.TextStyle(font: regular, fontSize: 8, color: _muted),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        );
      },
      build: (context) => [
        _header(logoBytes, semi, bold),
        pw.SizedBox(height: 18),
        pw.Text(
          name.toUpperCase(),
          style: pw.TextStyle(
            font: bold,
            fontSize: 20,
            color: _purple,
            letterSpacing: 0.2,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${ativacao.raca} · Nascido em $nascimento · Swab ${ativacao.swab} · Registro/Microchip: $registro / $chip',
          style: pw.TextStyle(font: regular, fontSize: 8.5, color: _muted),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Tutor: ${ativacao.nome_cliente}$endereco',
          style: pw.TextStyle(font: regular, fontSize: 8.5, color: _muted),
        ),
        pw.SizedBox(height: 14),
        _kpiRow(
          tested: tested,
          clear: clear,
          portadores: portadores,
          risco: risco,
          regular: regular,
          bold: bold,
        ),
        pw.SizedBox(height: 18),
        _sectionTitle('Achados que merecem atenção', bold),
        pw.Text(
          'Lista dos genes com 1 variante ou 2 variantes detectadas.',
          style: pw.TextStyle(font: regular, fontSize: 8.5, color: _muted),
        ),
        pw.SizedBox(height: 8),
        if (umaVariante.isEmpty && duasVariante.isEmpty)
          pw.Text(
            'Nenhum achado que mereça atenção neste painel.',
            style: pw.TextStyle(font: regular, fontSize: 9, color: _muted),
          )
        else ...[
          ...duasVariante.map((d) => _achadoCard(
                d,
                duasVariantes: true,
                regular: regular,
                semi: semi,
                bold: bold,
              )),
          ...umaVariante.map((d) => _achadoCard(
                d,
                duasVariantes: false,
                regular: regular,
                semi: semi,
                bold: bold,
              )),
        ],
        if (principais.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          _sectionTitle('Principais doenças genéticas da raça', bold),
          pw.Text(
            'Condições mais relevantes para ${ativacao.especie.toLowerCase() == 'felina' ? 'gatos' : 'cães'} da raça ${ativacao.raca}.',
            style: pw.TextStyle(font: regular, fontSize: 8.5, color: _muted),
          ),
          pw.SizedBox(height: 8),
          _principaisTable(
            principais,
            isFinding: isFinding,
            regular: regular,
            medium: medium,
            semi: semi,
          ),
        ],
        if (groupedTodas.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          _sectionTitle('Painel completo de doenças avaliadas', bold),
          pw.Text(
            '$tested variantes testadas em ${groupedTodas.length} categorias clínicas.',
            style: pw.TextStyle(font: regular, fontSize: 8.5, color: _muted),
          ),
          pw.SizedBox(height: 8),
          ...groupedTodas.entries.map((entry) {
            final hasFinding = entry.value.any(isFinding);
            return _categoryBlock(
              title: entry.key,
              items: entry.value,
              hasFinding: hasFinding,
              isFinding: isFinding,
              regular: regular,
              semi: semi,
            );
          }),
        ],
        if (groupedTracos.isNotEmpty) ...[
          pw.SizedBox(height: 18),
          _sectionTitle('Traços físicos e de pelagem', bold),
          pw.Text(
            'Genes que determinam aparência — não relacionados a risco de doença.',
            style: pw.TextStyle(font: regular, fontSize: 8.5, color: _muted),
          ),
          pw.SizedBox(height: 10),
          ...groupedTracos.entries.map((entry) => _tracosGroup(
                title: entry.key.toUpperCase(),
                items: entry.value,
                regular: regular,
                medium: medium,
                semi: semi,
              )),
        ],
      ],
    ),
  );

  return pdf.save();
}

pw.Widget _header(Uint8List logoBytes, pw.Font semi, pw.Font bold) {
  return pw.Column(
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Image(pw.MemoryImage(logoBytes), height: 36),
          pw.Spacer(),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'PAINEL SAÚDE',
                style: pw.TextStyle(
                  font: semi,
                  fontSize: 8,
                  color: _purple,
                  letterSpacing: 0.8,
                ),
              ),
              pw.Text(
                'BOX4PETS',
                style: pw.TextStyle(
                  font: bold,
                  fontSize: 9,
                  color: _purple,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Container(height: 1.2, color: _purple),
    ],
  );
}

pw.Widget _sectionTitle(String text, pw.Font bold) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Text(
      text,
      style: pw.TextStyle(font: bold, fontSize: 12.5, color: _text),
    ),
  );
}

pw.Widget _kpiRow({
  required int tested,
  required int clear,
  required int portadores,
  required int risco,
  required pw.Font regular,
  required pw.Font bold,
}) {
  pw.Widget card(String value, String label, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _line, width: 0.8),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(font: bold, fontSize: 18, color: color),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              label,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: regular, fontSize: 7.5, color: _muted),
            ),
          ],
        ),
      ),
    );
  }

  return pw.Row(
    children: [
      card('$tested', 'Genes testados', _purple),
      pw.SizedBox(width: 8),
      card(
        '$clear',
        portadores == 0
            ? 'Nenhum portador de 1 variante'
            : 'Portador: $portadores variante${portadores == 1 ? '' : 's'}',
        _green,
      ),
      pw.SizedBox(width: 8),
      card(
        '$risco',
        risco == 0
            ? 'Risco aumentado de doença:\nnenhuma com 2 variantes'
            : 'Risco aumentado de doença:\n2 variantes',
        _orange,
      ),
    ],
  );
}

pw.Widget _achadoCard(
  ListDoencasPdfModel d, {
  required bool duasVariantes,
  required pw.Font regular,
  required pw.Font semi,
  required pw.Font bold,
}) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _line, width: 0.8),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 3.5,
          height: 52,
          color: _orange,
        ),
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    _warnIcon(size: 11, bold: bold),
                    pw.SizedBox(width: 6),
                    pw.Expanded(
                      child: pw.Text(
                        d.doenca,
                        style: pw.TextStyle(
                            font: bold, fontSize: 10, color: _text),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '${d.categoria.toUpperCase()} · GENE ${_geneOf(d).toUpperCase()}',
                  style: pw.TextStyle(
                    font: semi,
                    fontSize: 7.5,
                    color: _muted,
                    letterSpacing: 0.4,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  _achadoDescricao(duasVariantes: duasVariantes),
                  style: pw.TextStyle(font: regular, fontSize: 8.5, color: _text),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _principaisTable(
  List<ListDoencasPdfModel> items, {
  required bool Function(ListDoencasPdfModel) isFinding,
  required pw.Font regular,
  required pw.Font medium,
  required pw.Font semi,
}) {
  return pw.Table(
    columnWidths: const {
      0: pw.FlexColumnWidth(4.6),
      1: pw.FlexColumnWidth(1.4),
      2: pw.FlexColumnWidth(2.2),
    },
    children: [
      pw.TableRow(
        children: [
          _th('DOENÇA', semi),
          _th('GENE', semi),
          _th('RESULTADO', semi, align: pw.TextAlign.right),
        ],
      ),
      ...items.map((d) {
        final finding = isFinding(d);
        final result = finding
            ? (_isClear(d.resultado) ? 'Uma variante detectada' : _resultadoHumano(d.resultado))
            : 'Não detectada';
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 5),
              child: pw.Row(
                children: [
                  _statusMark(warning: finding, bold: semi, size: 8),
                  pw.SizedBox(width: 5),
                  pw.Expanded(
                    child: pw.Text(
                      d.doenca,
                      style: pw.TextStyle(
                        font: medium,
                        fontSize: 8,
                        color: finding ? _orange : _text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 5),
              child: pw.Text(
                _geneOf(d),
                style: pw.TextStyle(font: regular, fontSize: 8, color: _muted),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 5),
              child: pw.Text(
                result,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: semi,
                  fontSize: 8,
                  color: finding ? _orange : _green,
                ),
              ),
            ),
          ],
        );
      }),
    ],
  );
}

pw.Widget _th(String text, pw.Font semi, {pw.TextAlign align = pw.TextAlign.left}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(
        font: semi,
        fontSize: 7,
        color: _muted,
        letterSpacing: 0.5,
      ),
    ),
  );
}

pw.Widget _categoryBlock({
  required String title,
  required List<ListDoencasPdfModel> items,
  required bool hasFinding,
  required bool Function(ListDoencasPdfModel) isFinding,
  required pw.Font regular,
  required pw.Font semi,
}) {
  final mid = (items.length / 2).ceil();
  final left = items.sublist(0, mid);
  final right = items.sublist(mid);

  pw.Widget nameCol(List<ListDoencasPdfModel> col) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: col
          .map(
            (d) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2.2),
              child: pw.Text(
                d.doenca,
                style: pw.TextStyle(
                  font: regular,
                  fontSize: 7.4,
                  color: isFinding(d) ? _orange : _text,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            _statusMark(warning: hasFinding, bold: semi, size: 9),
            pw.SizedBox(width: 5),
            pw.Text(
              '$title — ${items.length} testada${items.length == 1 ? '' : 's'}',
              style: pw.TextStyle(
                font: semi,
                fontSize: 9,
                color: hasFinding ? _orange : _purple,
              ),
            ),
          ],
        ),
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 3, bottom: 6),
          height: 0.6,
          color: _line,
        ),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: nameCol(left)),
            pw.SizedBox(width: 16),
            pw.Expanded(child: nameCol(right)),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _tracosGroup({
  required String title,
  required List<ListTracosPdf> items,
  required pw.Font regular,
  required pw.Font medium,
  required pw.Font semi,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: semi,
            fontSize: 8,
            color: _purple,
            letterSpacing: 0.6,
          ),
        ),
        pw.SizedBox(height: 4),
        ...items.map((t) {
          final genotype = (t.resultado ?? '').trim().isEmpty ? '—' : t.resultado!.trim();
          final notable = !_isClear(t.resultado) && genotype != '—';
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3.5),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Text(
                    t.tracos,
                    style: pw.TextStyle(font: medium, fontSize: 8, color: _text),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    genotype,
                    style: pw.TextStyle(
                      font: semi,
                      fontSize: 8,
                      color: notable ? _teal : _muted,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 5,
                  child: pw.Text(
                    _tracoInterpretacao(t),
                    style: pw.TextStyle(font: regular, fontSize: 7.5, color: _muted),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ),
  );
}

String _tracoInterpretacao(ListTracosPdf t) {
  final result = (t.resultado ?? '').trim();
  if (_isClear(result)) {
    return t.gene.trim().isEmpty
        ? 'Não portador.'
        : 'Não portador${t.gene.trim().isEmpty ? '.' : ' — ${t.gene}.'}';
  }
  if (result.contains('/') || result.contains(' ')) {
    return t.gene.trim().isEmpty ? 'Resultado: $result.' : 'Resultado $result (${t.gene}).';
  }
  return result;
}

String _resultadoHumano(String? raw) {
  final v = (raw ?? '').trim();
  if (v.toLowerCase().contains('duas') || v == '2') {
    return 'Duas variantes detectadas';
  }
  if (v.toLowerCase().contains('uma') || v == '1') {
    return 'Uma variante detectada';
  }
  return v.isEmpty ? 'Uma variante detectada' : v;
}

Map<String, List<T>> _groupBy<T>(List<T> items, String Function(T) keyOf) {
  final map = <String, List<T>>{};
  for (final item in items) {
    map.putIfAbsent(keyOf(item), () => []).add(item);
  }
  return map;
}
