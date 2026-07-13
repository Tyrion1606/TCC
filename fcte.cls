%% Programa de pós-graduação / graduação em Engenharia -- PPGEB/FCTE/UnB
%% Classe LaTeX para Trabalho de Conclusão de Curso
%% Arquivo reformulado a partir de fga.cls
%% Correções principais:
%%   - metadados opcionais inicializados corretamente;
%%   - bloco de coautor condicionado em todas as páginas de título;
%%   - uso de \RequirePackage em classe;
%%   - carregamento de geometry, necessário para \newgeometry/\restoregeometry;
%%   - \maketitle separado por responsabilidades.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{fcte}[2026/06/28 Classe PPGEB/FCTE v1.5]

% -----------------------------------------------------------------------------
% 1. Classe base e opções
% -----------------------------------------------------------------------------
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{report}}
\ExecuteOptions{a4paper,12pt,oneside,onecolumn,final,openany}
\ProcessOptions\relax

\LoadClass{report}

% -----------------------------------------------------------------------------
% 2. Pacotes
% -----------------------------------------------------------------------------
\RequirePackage[brazil]{babel}
\RequirePackage{pdfpages}
\RequirePackage{graphicx}
\RequirePackage{bold-extra}
\RequirePackage{ifthen}
\RequirePackage{lastpage}
\RequirePackage{color}
\RequirePackage{tabularx}
\RequirePackage{calc}
\RequirePackage{flafter}
\RequirePackage{scalefnt}
\RequirePackage[a4paper,margin=1in]{geometry}
\RequirePackage{array}
\RequirePackage{booktabs}
\RequirePackage{longtable}
\RequirePackage{multirow}
\RequirePackage{colortbl}
\RequirePackage{amsmath}
\RequirePackage{amssymb}
\RequirePackage{xfrac}
\RequirePackage{float}
\RequirePackage{placeins}
\RequirePackage{realboxes}
\RequirePackage{rotating}
\RequirePackage{subcaption}
\RequirePackage[margin=0.40in,font=small,labelfont=bf,labelsep=period]{caption}
\RequirePackage{enumerate}
\RequirePackage{indentfirst}
\RequirePackage{multicol}
\RequirePackage{pdflscape}
\RequirePackage{setspace}
\RequirePackage{xurl}
\RequirePackage{hyperref}
\RequirePackage{tikz}


% -----------------------------------------------------------------------------
% 3. Configurações gerais
% -----------------------------------------------------------------------------
\pagestyle{plain}
\raggedbottom
\onehalfspacing
\setlength{\parindent}{20pt}
\setlength{\parskip}{12pt}
\emergencystretch=2em
\setcounter{secnumdepth}{3}
\graphicspath{{figuras/}}
\usetikzlibrary{positioning, arrows.meta, calc}

\hypersetup{
  colorlinks=true,
  citecolor=blue,
  filecolor=blue,
  linkcolor=black,
  urlcolor=blue
}

\newcommand{\maiusc}[1]{\textsc{#1}}

\newcommand{\indice}{%
  \tableofcontents
  \listoftables
  \listoffigures
  \clearpage
}

% -----------------------------------------------------------------------------
% 4. Formatação dos capítulos
% -----------------------------------------------------------------------------

% Capítulos numerados: "1 Título do capítulo"
\def\@makechapterhead#1{%
  \vspace*{50\p@}%
  {%
    \parindent\z@
    \raggedright
    \normalfont
    \interlinepenalty\@M

    \Large\bfseries
    \ifnum\c@secnumdepth>\m@ne
      \maiusc{\thechapter}\hspace{0.6em}%
    \fi
    \maiusc{#1}\par\nobreak

    \vskip 40\p@
  }%
}

% Capítulos sem numeração: \chapter*{...}
\def\@makeschapterhead#1{%
  \vspace*{50\p@}%
  {%
    \parindent\z@
    \raggedright
    \normalfont
    \interlinepenalty\@M

    \Large\bfseries
    \maiusc{#1}\par\nobreak

    \vskip 40\p@
  }%
}

% -----------------------------------------------------------------------------
% 5. Metadados do trabalho
% -----------------------------------------------------------------------------
% Campos obrigatórios usam erro explícito caso sejam esquecidos.
\newcommand{\fcte@campoObrigatorio}[1]{%
  \ClassError{fcte}{Campo obrigatorio nao informado: #1}%
  {Defina o campo no preambulo do documento antes de chamar \string\maketitle.}%
}

\newcommand{\fcte@ifempty}[3]{%
  \begingroup
    \edef\fcte@tmp{#1}%
    \ifx\fcte@tmp\@empty
      \endgroup #2%
    \else
      \endgroup #3%
    \fi
}

\newcommand{\nomeinvertido}[1]{\gdef\@nomeinvertido{#1}}
\newcommand{\coauthor}[1]{\gdef\@coauthor{#1}}
\newcommand{\orientador}[1]{\gdef\@orientador{#1}}
\newcommand{\coorientador}[1]{\gdef\@coorientador{#1}}
\newcommand{\publicacao}[1]{\gdef\@publicacao{#1}}
\newcommand{\data}[1]{\gdef\@data{#1}}
\newcommand{\tituloficha}[1]{\gdef\@tituloficha{#1}}
\newcommand{\titulocapaA}[1]{\gdef\@titulocapaA{#1}}
\newcommand{\titulocapaB}[1]{\gdef\@titulocapaB{#1}}
\newcommand{\titulocapaC}[1]{\gdef\@titulocapaC{#1}}
\newcommand{\titulofichadois}[1]{\gdef\@titulofichadois{#1}}
\newcommand{\ano}[1]{\gdef\@ano{#1}}
\newcommand{\email}[1]{\gdef\@email{#1}}
\newcommand{\coemail}[1]{\gdef\@coemail{#1}}
\newcommand{\cep}[1]{\gdef\@cep{#1}}
\newcommand{\areaum}[1]{\gdef\@areaum{#1}}
\newcommand{\areadois}[1]{\gdef\@areadois{#1}}
\newcommand{\areatres}[1]{\gdef\@areatres{#1}}
\newcommand{\areaquatro}[1]{\gdef\@areaquatro{#1}}
\newcommand{\membrobancainterno}[1]{\gdef\@membrobancainterno{#1}}
\newcommand{\membrobancaexterno}[1]{\gdef\@membrobancaexterno{#1}}
\newcommand{\arquivocapa}[1]{\gdef\@arquivocapa{#1}}

% Valores iniciais. Campos opcionais começam vazios para não quebrar \maketitle.
\nomeinvertido{\fcte@campoObrigatorio{\string\nomeinvertido}}
\orientador{\fcte@campoObrigatorio{\string\orientador}}
\publicacao{}
\data{\fcte@campoObrigatorio{\string\data}}
\tituloficha{\fcte@campoObrigatorio{\string\tituloficha}}
\titulocapaA{}
\titulocapaB{}
\titulocapaC{}
\titulofichadois{\fcte@campoObrigatorio{\string\titulofichadois}}
\ano{\fcte@campoObrigatorio{\string\ano}}
\email{\fcte@campoObrigatorio{\string\email}}
\cep{}
\coauthor{}
\coemail{}
\coorientador{}
\areaum{}
\areadois{}
\areatres{}
\areaquatro{}
\membrobancainterno{}
\membrobancaexterno{}
\arquivocapa{capa}

% -----------------------------------------------------------------------------
% 6. Componentes reutilizáveis das páginas iniciais
% -----------------------------------------------------------------------------
\newcommand{\fcte@cabecalhoInstitucional}{%
  \begin{center}
    \begin{large}
      {\bfseries\maiusc{Universidade de Brasília -- UnB}}\\[7pt]
      {\bfseries\maiusc{Faculdade de Ciências e Tecnologias em Engenharia -- FCTE}}\\[10pt]
      {\bfseries\maiusc{Engenharia Eletrônica}}
    \end{large}
  \end{center}
}

\newcommand{\fcte@autoresTabular}{%
  \begin{tabular}[t]{c}
    {\bfseries\large\maiusc{\@author}\par}
    \fcte@ifempty{\@coauthor}{}{\\ {\bfseries\large\maiusc{\@coauthor}\par}}
  \end{tabular}%
}

\newcommand{\fcte@linhaOrientacao}{%
  {\bfseries\large\maiusc{Orientador: \@orientador}\par\vspace{10pt}}%
  \fcte@ifempty{\@coorientador}{}{%
    {\bfseries\large\maiusc{Co-orientador: \@coorientador}\par}%
  }%
}

\newcommand{\fcte@assinatura}[2]{%
  \begin{minipage}[t]{0.45\textwidth}
    \centering
    \underline{\hspace{60mm}}\\
    #1%
    \fcte@ifempty{#2}{}{\\#2}%
  \end{minipage}%
}

% -----------------------------------------------------------------------------
% 7. Partes do \maketitle
% -----------------------------------------------------------------------------
\newcommand{\fcte@capa}{%
  \thispagestyle{empty}%
  \IfFileExists{\@arquivocapa.pdf}{%
    \includepdf[pages=1,scale=1.0,frame=false,offset=0 0,pagecommand={%
      \vspace*{70mm}
      \begin{center}
        \scalebox{1.1}{\sffamily Universidade de Brasília -- UnB}\\
        \scalebox{1.2}{\sffamily Faculdade de Ciências e Tecnologias em Engenharia -- FCTE}\\
        \scalebox{1.2}{\sffamily Engenharia Eletrônica}\\[45pt]
        \vfill
        \makebox[\linewidth][c]{%
          \scalebox{1.3}{\maiusc{\textbf{\@titulocapaA}}}%
        }\\[5pt]
        \makebox[\linewidth][c]{%
            \scalebox{1.3}{\maiusc{\textbf{\@titulocapaB}}}%
        }\\[5pt]
        \makebox[\linewidth][c]{%
            \scalebox{1.3}{\maiusc{\textbf{\@titulocapaC}}}%
        }\\[15pt]
        \scalebox{1.2}{\maiusc{\textbf{\@author}}}%
        \fcte@ifempty{\@coauthor}{}{\\\scalebox{1.2}{\maiusc{\textbf{\@coauthor}}}}%
        \vfill
        \scalebox{1.0}{Orientador: Dr. \maiusc{\@orientador}}\\
        \fcte@ifempty{\@coorientador}{}{\scalebox{1.0}{Coorientador: Dr. \maiusc{\@coorientador}}}%
      \end{center}%
    }]{\@arquivocapa}%
  }{%
    \begin{center}
      \vspace*{40mm}
      {\sffamily Universidade de Brasília -- UnB}\\
      {\sffamily Faculdade de Ciências e Tecnologias em Engenharia -- FCTE}\\
      {\sffamily Engenharia Eletrônica}\\[45pt]
      \vfill
      {\bfseries\Large\maiusc{\@title}}\\[15pt]
      {\bfseries\large\maiusc{\@author}}%
      \fcte@ifempty{\@coauthor}{}{\\{\bfseries\large\maiusc{\@coauthor}}}%
      \vfill
      Orientador: Dr. \maiusc{\@orientador}\\
      \fcte@ifempty{\@coorientador}{}{Coorientador: Dr. \maiusc{\@coorientador}}%
    \end{center}
  }%
  \clearpage
}

\newcommand{\fcte@folhaDeRosto}{%
  \fcte@cabecalhoInstitucional
  \null\vfil
  \vskip 60\p@
  \begin{center}
    {\bfseries\large\maiusc{\@title}\par}
    \vskip 2.5em
    {\large\lineskip .75em\fcte@autoresTabular\par}
    \vfill
    \fcte@linhaOrientacao
    \vspace{20pt}
    {\bfseries\large\maiusc{Trabalho de Conclusão de Curso\\ Engenharia Eletrônica}\par}
    \vspace{24pt}
    {\bfseries\large\maiusc{Brasília/DF, \@data}\par}
  \end{center}
  \clearpage
}

\newcommand{\fcte@folhaDeAprovacao}{%
  \vspace*{-70pt}
  \fcte@cabecalhoInstitucional
  \begin{center}
    {\bfseries\large\maiusc{\@title}\par}
    \vskip 1em
    {\large\lineskip .75em\fcte@autoresTabular\par}
  \end{center}
  \vspace{6pt}
  \noindent{\bfseries\maiusc{Trabalho de Conclusão de Curso submetido à Faculdade de Ciências e Tecnologias em Engenharia da Universidade de Brasília, como parte dos requisitos necessários para a obtenção do grau de bacharel em engenharia eletrônica}\par}
  \vspace{24pt}
  \noindent{\bfseries\large\maiusc{Aprovada por:}\par}
  \vfill

  \noindent\underline{\hspace{100mm}}\\
  \noindent{\bfseries\@orientador}\\
  \noindent{\bfseries(Orientador)}
  \vfill

  \fcte@ifempty{\@membrobancainterno}{}{%
    \noindent\underline{\hspace{100mm}}\\
    \noindent{\bfseries\@membrobancainterno}
    \vfill
  }%

  \fcte@ifempty{\@membrobancaexterno}{}{%
    \noindent\underline{\hspace{100mm}}\\
    \noindent{\bfseries\@membrobancaexterno}
    \vfill
  }%
  \clearpage
}

\newcommand{\fcte@fichaCatalografica}{%
  \newgeometry{bottom=0.7in,top=0.4in,left=1in,right=1in}

  \begin{bfseries}
    \noindent\maiusc{Brasília/DF, \@data}
    \vfill
    \noindent\maiusc{Ficha Catalográfica}
  \end{bfseries}

  \noindent\begin{tabular}{|l|}
    \hline
    \maiusc{\@nomeinvertido}\\
    \@tituloficha{}\\
    {\pageref{LastPage}p.}, 210 ${\times}$ 297 mm (FCTE/UnB Gama, Bacharelado em Engenharia Eletrônica, \@ano).\\
    Trabalho de Conclusão de Curso, Faculdade de Ciências e Tecnologias em Engenharia,\\ Engenharia Eletrônica\\
    \begin{tabular}{lll}
      1. \@areaum{}   & \hspace*{10mm} & 2. \@areadois{}\\
      3. \@areatres{} &                  & 4. \@areaquatro{}\\
      I. FCTE UnB/UnB. &                 & II. Título (série)
    \end{tabular}\\
    \hline
  \end{tabular}

  \vspace*{12pt}
  \vfill

  \noindent{\bfseries\maiusc{Referência}}

  \noindent\maiusc{\@nomeinvertido} (\@ano). \@titulofichadois. Trabalho de Conclusão de Curso, Engenharia Eletrônica, Faculdade de Ciências e Tecnologias em Engenharia, Universidade de Brasília, Brasília, DF, \pageref{LastPage}p.

  \vspace{12pt}
  \vfill

  \noindent{\bfseries\maiusc{Cessão de Direitos}}

  \noindent\maiusc{Autores: }\@author
  \fcte@ifempty{\@coauthor}{}{ e \@coauthor}\\[3pt]
  \noindent\maiusc{Título: } \@titulofichadois\\[3pt]
  \noindent\maiusc{Grau: } Bacharel em Engenharia Eletrônica\\[3pt]
  \noindent\maiusc{Ano: } \@ano\\[12pt]
  \noindent É concedida à Universidade de Brasília permissão para reproduzir cópias desta monografia de conclusão de curso e para emprestar ou vender tais cópias somente para propósitos acadêmicos e científicos. O autor reserva outros direitos de publicação e nenhuma parte desta monografia pode ser reproduzida sem a autorização por escrito do autor.\\[36pt]

  \vfill

  \noindent
  \fcte@assinatura{\@author}{\@email}%
  \fcte@ifempty{\@coauthor}{}{%
    \hfill
    \fcte@assinatura{\@coauthor}{\@coemail}%
  }

  \vspace{12pt}
  \noindent Brasília, DF -- Brasil

  \restoregeometry
}

% -----------------------------------------------------------------------------
% 8. Montagem final das páginas pré-textuais
% -----------------------------------------------------------------------------
\renewcommand{\maketitle}{%
  \begingroup
    \let\footnotesize\small
    \let\footnoterule\relax
    \let\footnote\thanks

    \pagenumbering{roman}

    \fcte@capa
    \fcte@folhaDeRosto
    \fcte@folhaDeAprovacao
    \fcte@fichaCatalografica
  \endgroup

  \setcounter{footnote}{0}%
  \global\let\thanks\relax
  \global\let\maketitle\relax
  \global\let\@thanks\@empty
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\title\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
}


% -----------------------------------------------------------------------------
% 9. Formatação de títulos, comandos auxiliares e ambientes pré-textuais
% -----------------------------------------------------------------------------
\makeatletter
\renewcommand{\section}{\@startsection
  {section}{1}{0mm}{-\baselineskip}{0.5\baselineskip}{\large\bfseries}}

\renewcommand{\subsection}{\@startsection
  {subsection}{2}{0mm}{-\baselineskip}{0.5\baselineskip}{\bfseries\sffamily}}

\renewcommand{\subsubsection}{\@startsection
  {subsubsection}{3}{0mm}{-\baselineskip}{0.5\baselineskip}{\bfseries\sffamily}}
\makeatother

% Referências cruzadas.
\newcommand{\subsecref}[1]{Seção~\ref{#1}}
\newcommand{\figref}[1]{Figura~\ref{#1}}

% Termos recorrentes.
\newcommand{\etal}{\emph{et~al.}}
\newcommand{\scanner}{\emph{scanner}}
\newcommand{\scanners}{\emph{scanners}}
\newcommand{\software}{\emph{software}}
\newcommand{\Jawsonly}{{\emph{Jaws-Only}} }
\newcommand{\jawsonly}{{\emph{jaws-only}} }

% Símbolos e unidades.
\newcommand{\spaceinitialsname}{0.4mm}
\newcommand{\percentagesignscale}{0.9}
\newcommand{\porcento}{\scalebox{0.5}{~}\scalebox{0.9}{\%}}
\newcommand{\cmquad}{${\textrm{cm}^{\scalebox{0.7}{2}} }$}
\newcommand{\mmquad}{${\textrm{mm}^{\scalebox{0.7}{2}} }$}
\newcommand{\cmcubico}{${\textrm{cm}^{\scalebox{0.7}{3} }}$}
\newcommand{\gcmquad}{${\textrm{g}}/{\textrm{cm}^{\scalebox{0.7}{2}} }$}

% Atalhos de seção.
\newcommand{\Section}[1]{\section{\textbf{#1} }}
\newcommand{\Sectionlabel}[2]{\section{\textbf{#1}\label{#2} }}
\newcommand{\subsubsubsection}[1]{\vspace{16pt}\noindent\textbf{#1}\\[12pt]}
\newcommand{\commenttext}[1]{}

% Ambientes pré-textuais.
\newenvironment{resumo}{%
  \newgeometry{bottom=0.8in,top=0.9in,left=0.9in,right=0.9in}%
  \noindent{\bfseries\maiusc{\large Resumo}}\par\vspace{12pt}%
}{%
  \clearpage\restoregeometry%
}

\newenvironment{abstractfcte}{%
  \noindent{\bfseries\maiusc{\large Abstract}}\par\vspace{24pt}%
}{%
  \clearpage%
}

\newenvironment{simbolos}{%
  \begin{center}{\bfseries\maiusc{\large Lista de Símbolos, Nomenclaturas e Abreviações}}\end{center}%
  \noindent\begin{tabular}{rcl}%
}{%
  \end{tabular}\clearpage%
}

\newcommand{\simbolo}[2]{\emph{#1} & -- & \emph{#2}\\}

% Bibliografia padrão do template.
\newcommand{\fcteBibliografiaNumerica}{\bibliographystyle{unsrt}}
\newcommand{\fcteBibliografiaAutorAno}{\RequirePackage{apalike}\bibliographystyle{apalike}}

% Hifenização padrão herdada do documento-base.
\hyphenation{
  development
  results
  Commissioning
  possibility
  Philadelphia
  Devic
  Calculations
  Calculation
}

% -----------------------------------------------------------------------------
% 10. Nomes em português para sumário, listas e bibliografia
% -----------------------------------------------------------------------------
\addto\captionsbrazil{%
  \renewcommand{\contentsname}{\centering{\bfseries\maiusc{\large Sumário}}\\\vspace*{-24pt}}%
  \renewcommand{\listfigurename}{\centering{\bfseries\maiusc{\large Lista de Figuras}}\\\vspace*{-24pt}}%
  \renewcommand{\listtablename}{\centering{\bfseries\maiusc{\large Lista de Tabelas}}\\\vspace*{-24pt}}%
  \renewcommand{\bibname}{Bibliografia}%
}

\endinput
