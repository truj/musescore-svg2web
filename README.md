# What

This repository provides scripts to clean up SVG files produced by Musescore and copies them in a way that they can be used directly inside a web project using partials (e.g. foundation-cli).

The scripts perform the following tasks:

- Resizing the SVG to match the drawing (cutting away unneeded space)
- Removing style information that can also be provided as CSS.
- Removing unnecessary tags and most whitespaces.
- Copying the result to an intermediate file
- On user interaction: Moves the result file to the target directory configured in the script itself.

# Why

For the MidicaPL tutorial in https://github.com/truj/midica.org I need to include a lot
of SVGs as example scores. As midica.org is a foundation project using handlebars, the SVGs are all included as partials.

I began with Musescore 2 and created a small perl script doing the cleanup and copy tasks.
Later I switched to Musescore 3.

The exported SVGs need different CSS styles, depending on the Musescore version.
That's why we have 2 scripts now.

# Requirements

- Unix-like OS
- Perl
- Musescore (Version 2 or 3)
- Inkscape
- Web project supporting partials (e.g. foundation) - like midica.org

# Getting started

- `git clone git@github.com:truj/musescore-svg2web.git`
- Open `clean_m2.pl` and/or `clean_m3.pl` with a text editor and adjust the line beginning with `my $TARGET_DIR = ...` to your needs. This is the directory where you want the cleaned SVGs to be copied into.
- Create your score with Musescore. Adjust the size:
  - Musescore 2: right-click > page settings. Then change the width.
  - Musescore 3: Format > page settings. Then change the width.
- Export your svg file from Musescore and save it in the same directory like clean_m2.pl or clean_m3.pl
- If you use Musescore 2 to export the SVG, you need `clean_m2.pl` for the cleanup. If you use Musescore 3, you need `clean_m3.pl`.
- Call the script and provide the SVG's filename as the only parameter.
- Depending on some circumstances, inkscape may open the save dialog. In this case, click on save, and inkscape closes again.
- After the script has created the intermediate file, it shows the move command it wants to perform. Type upper-cased 'Y' and enter, if you agree. Then the file will be moved.
- In your web project, add a SASS or CSS file containing the needed classes. Otherwise your SVG looks crippled because the style information is missing.

Get inspiration by the following SASS file: https://github.com/truj/midica.org/blob/master/src/assets/scss/pages/midicapl.scss

What you need is something like this:

```
svg {
	margin: 0.5rem;
	polyline {
		&.StaffLines {
			stroke: #000000;
			stroke-width: 0.40000001;
			fill: none;
			stroke-linejoin: bevel;
			&.v3 {
				stroke-width: 2;
			}
		}
		&.BarLine {
			...
		}
		...
		...
	}
}
```

# Limits

- The source SVG file must be in the same directory as the script itself. (Should be trivial to fix but I won't do that unless someone needs it.)
- Only cares about the SVG elements and classes that I've been using in Musescore for midica.org so far. If I need more classes, I will add them when needed. If **you** need more, tell me or add them yourself (and tell me as well).
- Configuration of the target directory is hard-coded in the scripts themselves. Not good practice, but I don't care as long as nobody needs a cleaner solution.
