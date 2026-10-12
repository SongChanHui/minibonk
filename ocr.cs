using System;
using System.IO;
using System.Threading.Tasks;
using Windows.Storage;
using Windows.Graphics.Imaging;
using Windows.Media.Ocr;
using Windows.Globalization;

public class OcrHelper {
    public static async Task Run(string path) {
        var file = await StorageFile.GetFileFromPathAsync(Path.GetFullPath(path));
        using (var stream = await file.OpenAsync(FileAccessMode.Read)) {
            var decoder = await BitmapDecoder.CreateAsync(stream);
            var bitmap = await decoder.GetSoftwareBitmapAsync();
            var engine = OcrEngine.TryCreateFromUserProfileLanguages() ?? OcrEngine.TryCreateFromLanguage(new Language("ko"));
            var result = await engine.RecognizeAsync(bitmap);
            foreach (var line in result.Lines) {
                Console.WriteLine($"[{line.BoundingRect.X:F0},{line.BoundingRect.Y:F0} {line.BoundingRect.Width:F0}x{line.BoundingRect.Height:F0}] {line.Text}");
            }
        }
    }
}
