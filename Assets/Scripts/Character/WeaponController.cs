using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class WeaponController : MonoBehaviour
{

    [Header("Arrow Behaviour")]
    [SerializeField]
    private Weapon m_weapon;

    [SerializeField]
    private string m_enemyTag;

    [SerializeField]
    private float m_maxFirePower;

    [SerializeField]
    private float m_minFirePower;

    [SerializeField]
    private float m_firePowerSpeed;

    public float m_firePower;

    private bool m_fire;

    [Header("Crosshair reticle")]
    [SerializeField]
    private UI_Manager m_UI;

    [SerializeField]
    private float m_minRadius;

    private float m_currentRadius;

    [SerializeField]
    private float m_maxRadius;

    [SerializeField]
    private int m_Steps;

    [SerializeField]
    private float m_SpeedCircle;
    
    private float m_maxSpeedCircle;
    private float m_minSpeedCircle;

    [Header("Inputs")]
    [SerializeField]
    private PlayerInput playerInput;
    [SerializeField]
    private InputAction m_shootArrow;

    private void Awake()
    {
        playerInput = GetComponent<PlayerInput>();
        m_shootArrow = playerInput.actions["Shoot"];
        m_fire = false;

        m_minRadius = 3f;
        m_currentRadius = 50f;
        m_maxRadius = 50f;
        m_Steps = 1000;
        m_SpeedCircle = 5f;
        m_maxSpeedCircle = 100f;
        m_minSpeedCircle = 50f;
    }

    private void Update()
    {
        m_firePowerSpeed = m_maxFirePower - m_minFirePower;
        if (m_shootArrow.triggered)
        {
            m_firePower = m_minFirePower;
            m_fire = true;
        }

        if (m_fire)
        {
            if (m_firePower < m_maxFirePower)
            {
                m_firePower += Time.deltaTime * m_firePowerSpeed;
            }
            
            m_SpeedCircle += Time.deltaTime * 40f;
            m_currentRadius -= Time.deltaTime * m_SpeedCircle;
        }
        else
        {
            m_SpeedCircle -= Time.deltaTime * 50f;
            m_currentRadius += Time.deltaTime * m_SpeedCircle;
        }

        if (m_shootArrow.WasReleasedThisFrame())
        {
            if(m_firePower >= (m_minFirePower + ((m_maxFirePower - m_minFirePower) / 2)))
            {
                m_weapon.FireArrow(m_firePower, false);
            }
            else
            {
                m_weapon.FireArrow(m_firePower, true);
            }
            m_fire = false;
        }

        checkRadiusCircle();

        m_UI.SetAlphaCirlce(UtilsGyromitra.InversedNormalizedFloatFromARange(m_maxRadius, m_minRadius, m_currentRadius));

        m_UI.DrawCircle(m_Steps, m_currentRadius);
    }

    /// <summary>
    /// Check if the radius of the reticle for his max and min radius
    /// </summary>
    private void checkRadiusCircle()
    {
        if (m_currentRadius <= m_minRadius) m_currentRadius = m_minRadius;
        if (m_currentRadius >= m_maxRadius) m_currentRadius = m_maxRadius;
        if (m_SpeedCircle <= m_minSpeedCircle) m_SpeedCircle = m_minSpeedCircle;
        if (m_SpeedCircle >= m_maxSpeedCircle) m_SpeedCircle = m_maxSpeedCircle;
    }
}
