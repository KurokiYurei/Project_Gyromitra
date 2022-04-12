using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class WeaponController : MonoBehaviour
{
    [SerializeField]
    private Weapon m_weapon;

    [SerializeField]
    private string m_enemyTag;

    [SerializeField]
    private float m_maxFirePower;

    [SerializeField]
    private float m_firePowerSpeed;

    private float m_firePower;

    [SerializeField]
    private float m_rotateSpeed;

    //[SerializeField]
    //private float m_minRotation;

    //[SerializeField]
    //private float m_maxRotation;

    //private float m_mouseY;

    private bool m_fire;

    [Header("Inputs")]
    private PlayerInput playerInput;
    private InputAction m_shootArrow;

    private void Awake()
    {
        playerInput = GetComponent<PlayerInput>();
        m_shootArrow = playerInput.actions["Shoot"];
        m_weapon.SetEnemyTag(UtilsGyromitra.SearchForTag(m_enemyTag));
        m_weapon.Reload();
        m_fire = false;
    }

    private void Update()
    {

        // canviar la posicio del arc depenent de la posicio del ratoli
        /*
        m_mouseY -= Input.GetAxis("Mouse Y") * m_rotateSpeed;
        m_mouseY = Mathf.Clamp(m_mouseY, m_minRotation, m_maxRotation);
        m_weapon.transform.localRotation = Quaternion.Euler(m_mouseY, m_weapon.transform.localEulerAngles.y, m_weapon.transform.localEulerAngles.z);
        */

        // canviar a input system nou
        if (Input.GetMouseButtonDown(0))
        {
            m_fire = true;
        }

        if (m_fire && m_firePower < m_maxFirePower)
        {
            m_firePower += Time.deltaTime * m_firePowerSpeed;
        }

        if (Input.GetMouseButtonUp(0))
        {
            m_weapon.FireArrow(m_firePower);
            m_firePower = 0f;
            m_fire = false;
        }

    }
}
