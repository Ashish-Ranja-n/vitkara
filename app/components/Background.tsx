"use client";
import React, { useRef, useEffect } from "react";

const Background = () => {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    let width = (canvas.width = window.innerWidth);
    let height = (canvas.height = window.innerHeight);
    let particles: Particle[] = [];

    window.addEventListener("resize", () => {
      width = canvas.width = window.innerWidth;
      height = canvas.height = window.innerHeight;
    });

    class Particle {
      x: number;
      y: number;
      dirX: number;
      dirY: number;
      size: number;
      color: string;

      constructor(x: number, y: number, dirX: number, dirY: number, size: number, color: string) {
        this.x = x;
        this.y = y;
        this.dirX = dirX;
        this.dirY = dirY;
        this.size = size;
        this.color = color;
      }

      draw() {
        ctx!.beginPath();
        ctx!.arc(this.x, this.y, this.size, 0, Math.PI * 2, false);
        ctx!.fillStyle = "rgba(100, 255, 255, 0.5)";
        ctx!.fill();
      }

      update() {
        if (this.x > width || this.x < 0) {
          this.dirX = -this.dirX;
        }
        if (this.y > height || this.y < 0) {
          this.dirY = -this.dirY;
        }
        this.x += this.dirX;
        this.y += this.dirY;
        this.draw();
      }
    }

    function init() {
      particles = [];
      const numberOfParticles = (canvas!.height * canvas!.width) / 9000;
      for (let i = 0; i < numberOfParticles; i++) {
        const size = Math.random() * 2 + 1;
        const x = Math.random() * (width - size * 2 - size * 2) + size * 2;
        const y = Math.random() * (height - size * 2 - size * 2) + size * 2;
        const dirX = Math.random() * 0.4 - 0.2;
        const dirY = Math.random() * 0.4 - 0.2;
        const color = "#e6e6e6";
        particles.push(new Particle(x, y, dirX, dirY, size, color));
      }
    }

    function connect() {
      let opacityValue = 1;
      for (let a = 0; a < particles.length; a++) {
        for (let b = a; b < particles.length; b++) {
          const distance =
            (particles[a].x - particles[b].x) * (particles[a].x - particles[b].x) +
            (particles[a].y - particles[b].y) * (particles[a].y - particles[b].y);
          if (distance < (width / 7) * (height / 7)) {
            opacityValue = 1 - distance / 20000;
            ctx!.strokeStyle = `rgba(100, 255, 255, ${opacityValue})`;
            ctx!.lineWidth = 1;
            ctx!.beginPath();
            ctx!.moveTo(particles[a].x, particles[a].y);
            ctx!.lineTo(particles[b].x, particles[b].y);
            ctx!.stroke();
          }
        }
      }
    }

    function animate() {
      requestAnimationFrame(animate);
      ctx!.clearRect(0, 0, width, height);
      for (let i = 0; i < particles.length; i++) {
        particles[i].update();
      }
      connect();
    }

    init();
    animate();

    return () => {
      window.removeEventListener("resize", () => {});
    };
  }, []);

  return <canvas ref={canvasRef} className="fixed top-0 left-0 w-full h-full -z-10 bg-black"></canvas>;
};

export default Background;
