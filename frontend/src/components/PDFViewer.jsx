import { useState, useEffect } from 'react';
import * as pdfjsLib from 'pdfjs-dist';
import { X, ChevronLeft, ChevronRight, ZoomIn, ZoomOut, CheckCircle } from 'lucide-react';
import QuizModal from './QuizModal';
import './PDFViewer.css';

// Set up the PDF.js worker using the bundled worker from pdfjs-dist
const pdfWorkerUrl = new URL(
  'pdfjs-dist/build/pdf.worker.min.mjs',
  import.meta.url,
).href;

pdfjsLib.GlobalWorkerOptions.workerSrc = pdfWorkerUrl;

const PDFViewer = ({ fileUrl, fileName, onClose, onProgressUpdate }) => {
  const [pdf, setPdf] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(0);
  const [zoom, setZoom] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [canvas, setCanvas] = useState(null);
  const [showQuiz, setShowQuiz] = useState(false);

  useEffect(() => {
    const loadPDF = async () => {
      try {
        setLoading(true);
        console.log('Loading PDF from URL:', fileUrl);
        const pdf = await pdfjsLib.getDocument(fileUrl).promise;
        setPdf(pdf);
        setTotalPages(pdf.numPages);
        setCurrentPage(1);
      } catch (err) {
        console.error('Error loading PDF:', err);
        setError('Không thể tải file PDF');
      } finally {
        setLoading(false);
      }
    };

    loadPDF();
  }, [fileUrl]);

  useEffect(() => {
    if (!pdf) return;

    const renderPage = async () => {
      try {
        const page = await pdf.getPage(currentPage);
        
        const viewport = page.getViewport({ scale: zoom });
        const canvasElement = document.getElementById('pdf-canvas');
        
        if (!canvasElement) return;

        const context = canvasElement.getContext('2d');
        canvasElement.width = viewport.width;
        canvasElement.height = viewport.height;

        const renderContext = {
          canvasContext: context,
          viewport: viewport,
        };

        await page.render(renderContext).promise;
      } catch (err) {
        console.error('Error rendering PDF page:', err);
      }
    };

    renderPage();
  }, [pdf, currentPage, zoom]);

  const handlePrevPage = () => {
    setCurrentPage(Math.max(1, currentPage - 1));
  };

  const handleNextPage = () => {
    setCurrentPage(Math.min(totalPages, currentPage + 1));
  };

  const handleZoomIn = () => {
    setZoom(Math.min(zoom + 0.2, 3));
  };

  const handleZoomOut = () => {
    setZoom(Math.max(zoom - 0.2, 0.5));
  };

  const handleCompleteLesson = () => {
    setShowQuiz(true);
  };

  const handleQuizComplete = (results) => {
    // Quiz completed - results contain score info
    console.log('Quiz completed:', results);
    
    // Notify parent to refresh progress
    if (onProgressUpdate) {
      onProgressUpdate();
    }
  };

  return (
    <>
      <div className="pdf-viewer-overlay">
        <div className="pdf-viewer-modal">
          {/* Header */}
          <div className="pdf-viewer-header">
            <h2>{fileName}</h2>
            <button
              className="pdf-viewer-close-btn"
              onClick={onClose}
              title="Đóng"
            >
              <X size={24} />
            </button>
          </div>

          {/* Content */}
          {loading ? (
            <div className="pdf-viewer-loading">
              <p>Đang tải PDF...</p>
            </div>
          ) : error ? (
            <div className="pdf-viewer-error">
              <p>{error}</p>
            </div>
          ) : (
            <>
              <div className="pdf-viewer-content">
                <canvas id="pdf-canvas"></canvas>
              </div>

              {/* Controls */}
              <div className="pdf-viewer-controls">
                <div className="pdf-controls-left">
                  <button
                    className="pdf-control-btn"
                    onClick={handlePrevPage}
                    disabled={currentPage === 1}
                    title="Trang trước"
                  >
                    <ChevronLeft size={20} />
                  </button>

                  <span className="pdf-page-info">
                    Trang {currentPage} / {totalPages}
                  </span>

                  <button
                    className="pdf-control-btn"
                    onClick={handleNextPage}
                    disabled={currentPage === totalPages}
                    title="Trang sau"
                  >
                    <ChevronRight size={20} />
                  </button>
                </div>

                <div className="pdf-controls-center">
                  <button
                    className="pdf-complete-btn"
                    onClick={handleCompleteLesson}
                    title="Hoàn thành bài học và làm quiz"
                  >
                    <CheckCircle size={20} />
                    <span>Hoàn thành & Làm Quiz</span>
                  </button>
                </div>

                <div className="pdf-controls-right">
                  <button
                    className="pdf-control-btn"
                    onClick={handleZoomOut}
                    disabled={zoom <= 0.5}
                    title="Thu nhỏ"
                  >
                    <ZoomOut size={20} />
                  </button>

                  <span className="pdf-zoom-info">{Math.round(zoom * 100)}%</span>

                  <button
                    className="pdf-control-btn"
                    onClick={handleZoomIn}
                    disabled={zoom >= 3}
                    title="Phóng to"
                  >
                    <ZoomIn size={20} />
                  </button>
                </div>
              </div>
            </>
          )}
        </div>
      </div>

      {/* Quiz Modal */}
      <QuizModal
        isOpen={showQuiz}
        onClose={() => setShowQuiz(false)}
        lessonFileName={fileName}
        lessonTitle={fileName.replace('.pdf', '')}
        onQuizComplete={handleQuizComplete}
      />
    </>
  );
};

export default PDFViewer;
